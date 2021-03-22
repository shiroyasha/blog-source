---
id: ab3093b6-6da3-4f64-a1bb-a5d67a7dbad8
title: Boolean short circuiting is not guaranteed
date: 2018-12-09
tags: programming, postgres
image: 2018-12-09-boolean-short-circuiting-is-not-guaranteed-in-sql.png
---

Last week I was debugging a weird bug in one of our services. In the logs we
saw an SQL error "repetition-operator operand invalid", so I was pretty sure
that we have a broken SQL comparison in one of our services. The weird part
was that this error happened only occasionally, seemingly randomly.

READMORE

After several hours of debugging, we learned something mind boggling at that
moment &mdash; boolean expressions in `where` statements are not short
circuited. This definitely clashed with our assumptions, and teched us an
important lesson to always double check our assumptions when designing a
system.

## The system that we debugged

In one of our services, we had a scheme where we construct *rules*, where each
rule is activated if it matches one or more regular expression patterns. For
example, the following rule would be "activated" by `master`, `staging-alpha`,
or `release-3`, but it wouldn't be activated by `feature/new-icons`.

``` yaml
rule:
  name: "non-feature-branches"
  patterns:
    - /^master$/
    - /^staging-.*$/
    - /^release-3$/
```

We were using this system to activate some features based on git branch names,
as you could already guess by the previous examples. A repository has multiple
rules in this context.

We encoded this information in the following SQL tables:

``` sql
table repository (
  id   integer
  name string
)

table rules (
  id      integer
  repo_id integer
  name    string
)

table patterns (
  rule_id integer
  term    string
)
```

The following query would list rules that are activated by a branch name:

``` sql
SELECT id FROM rules
WHERE rules.repo_id = ($1) AND EXISTS (
  SELECT 1 FROM patterns
  WHERE rule.id = patterns.rule_id AND ($2) ~ pattern.term
)
```

## The bug

As stated in the intro, the SQL error was `invalid regular expression: quantifier operand invalid`
which happens if you have an invalid regular expression in a SQL select
statement. In our case, the poisonous regular expression was `*`, which is
invalid, and should be `.*`.

The weird part was that the pattern was not part of the repository we were
filtering, and we were totally baffled why it is raised, if it should never
even be tested.

Here is our assumptions how the following query should have worked:

``` sql
SELECT id FROM rules
WHERE rules.repo_id = ($1) AND EXISTS (
  SELECT 1 FROM patterns
  WHERE rule.id = patterns.rule_id AND ($2) ~ pattern.term
)
```

1. First, we filter only repositories that we are interested in with `rules.repo_id = ($1)`
2. Then, we find the patterns associated with that subset with `rule.id = patterns.rule_id` in the inner query
3. Finally, we filter that subset with the innermost regex match `($2) ~ pattern.term`

Based on the previous assumption, and order of operations, even if we had a
broken rule in our system, it would only affect repositories that are using that
rule, but no others.

This was false. The order of operations is different in SQL, as there is no
short-circuiting between `AND` statements in an SQL query.

## How to prove that short-circuiting is not working?

We hypothesised that short-circuiting is not working, but we needed a proof.
SQL `explain` and `explain analyse` helped us to prove our hypothesis.

``` sql
EXPLAIN SELECT id FROM rules
        WHERE rules.repo_id = ($1) AND EXISTS (
          SELECT 1 FROM patterns
          WHERE rule.id = patterns.rule_id AND ($2) ~ pattern.term
        );

---

Nested Loop Semi Join  (cost=0.14..19.05 rows=1 width=16)
  Join Filter: (rules.id = patterns.rule_id)
  ->  Index Scan using rules_repo_id_index on rules (cost=0.14..8.16 rows=1 width=16)
        Index Cond: (repo_id = 1)
  ->  Materialize  (cost=0.00..10.88 rows=1 width=16)
        ->  Seq Scan on patterns  (cost=0.00..10.88 rows=1 width=16)
              Filter: ('master'::text ~ (term)::text)
```

Turns out the actual order of operations is:

1. First, the whole rules table is filtered based on `repo_id = 1`.
2. Then, then we find the first pattern that matches `'master'::text ~ (term)::text`
3. Finally, the join filter `rules.id = patterns.rule_id` is applied to combine the results

This was obviously in direct contradiction to our basic assumption that SQL
follows `AND` joins in order they appear, and short circuit if the first
expression is false.
