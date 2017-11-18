---
id: 6199153d-d06e-4b3a-a14f-e69c87ed59d9
title: Selecting for Share and Update in PostgreSQL
date: 2017-11-18
tags: programming
image: 2017-11-18-selecting-for-share-and-update-in-postgresql.png
---


A regular select statement does not give you enough protection if you want to
query data and make a change in the database related to it. Other transactions
can update or delete the data you just queried. PostgreSQL offers additional
select statements that lock on read and provide an extra layer of safety.

![Selecting for Share and Update](images/2017-11-18-selecting-for-share-and-update-in-postgresql.png)

This article explores the `select for share` and `select for update` statements,
locks that are created with these statements, and provide examples for using
these two select statements.

## Safely Updating Data

Sometimes, applications read data from the database, process the data, and save
the result back in the database. This is a classic example where the
`select for update` can provide additional safety.

Let's consider the following example:

``` sql
BEGIN;
SELECT * FROM purchases WHERE processed = false;

-- * application is now processing the purchases *

UPDATE purchases SET ...;
COMMIT;
```

The above code snippet can be a victim of a nasty race condition. The problem is
that some other part of the application can update the unprocessed data. Changes
to those rows will be then overwritten when the data processing finishes.

Here is an example scenario in which the data suffers from an intrusive race
condition.

``` sql
process A: SELECT * FROM purchases WHERE processed = false;

--- process B updates the data while process A is processing it
process B: SELECT * FROM purchases;
process B: UPDATE purchases SET ...;

process A: UPDATE purchases SET ...;
```

To mitigate this issue, we can _select the data for updating_. Here is an
example how we would do it:

``` sql
BEGIN;
SELECT * FROM purchases WHERE processed = false FOR UPDATE;

-- * application is now processing the purchases *

UPDATE purchases SET ...;
COMMIT;
```

The `select ... for update` acquires a `ROW SHARE LOCK` on a table. This lock
conflicts with the `EXCLUSIVE` lock needed for an `update` statement, and
prevents any changes that could happen concurrently.

``` sql
process A: SELECT * FROM purchases WHERE processed = false FOR UPDATE;
process B: SELECT * FROM purchases FOR UDPATE;
--- process B blocks blocks and waits process A to finish

process A: UPDATE purchases SET ...;
process B: UPDATE purchases SET ...;
```

All the locks will be released when the transaction ends.

## Non-blocking Select for Update Statements

When the applications selects some rows for update, other processes are forced
to wait for the transaction to end before they can get a hold of that lock.

If the processing takes too long to complete, for whatever reason, other parts
of the system might be blocked. This can be undesirable. We can use the
`select ... for update nowait` statement to prevent blocking calls to our
database. This query will error out if the rows are not available for selection.

``` sql
process A: SELECT * FROM purchases WHERE processed = false;

--- process B tries to select the data, but fails
process B: SELECT * FROM purchases FOR UPDATE NOWAIT;
process B: ERROR could not obtain lock on row in relation "purchases"

process A: UPDATE purchases SET ...;
```

## Processing Non-Locked Database Rows

Select for update can be a rigid lock on your table. Concurrent processes can be
blocked and starved out. Waiting is the slowest form of concurrent processing.
If only one CPU can be active at a time, it is pointless to scale your servers.
For this purpose, in PostgreSQL there is a mechanism for selecting only rows
that are not locked.

The `select ... for update skip locked` is a statement that allows you to query
rows that have no locks. Let's observe the following scenario to grasp its use
case:

``` sql
process A: SELECT * FROM purchases
process A:   WHERE processed = false FOR UPDATE SKIP LOCKED;

process B: SELECT * FROM purchases
process B:   WHERE created_at < now()::date - interval '1w';
process B:   FOR UPDATE SKIP LOCKED;

-- process A selects and locks all unprocess rows
-- process B selects all non locked purchases older than a week

process A: UPDATE purchases SET ...;
process B: UPDATE purchases SET ...;
```

Both Process A and Process B can process data concurrently.

## The Effect of Select For Update on Foreign Keys

One thing that we need to keep in mind while working with select for update
statements is its effect on foreign keys. More specifically, we can't forget
that the referenced rows from other tables are also locked.

Let's look at an example with two tables — users and purchases — with the notion
that users have many purchases.

``` sql
\d purchases

              Table "public.purchases"
 Column  |  Type   | Collation | Nullable | Default
---------+---------+-----------+----------+---------
 id      | integer |           |          |
 payload | jsonb   |           |          |
 user_id | integer |           |          |

Foreign-key constraints:
    "purchases_user_id_fkey" FOREIGN KEY (user_id) REFERENCES
    users(id) ON UPDATE CASCADE ON DELETE CASCADE
```

When selecting data from the purchases table with `select for update`, users
will be locked as well. This is necessary because otherwise there is a chance of
breaking the foreign-key constraint.

``` sql
process A: SELECT * FROM purchases FOR UPDATE;
process B: UPDATE users SET id = 3 WHERE id = 1;

-- process B is blocked and is waiting for process A to finish
-- its transaction
```

In bigger systems, a `select for share` can have huge negative consequences if
it locks a widely used table. Keep in mind that other processes will only need
to wait if they want to update the referenced field. If the other process wants
to update some unrelated data, no blocking will occur.

``` sql
process A: SELECT * FROM purchases FOR UPDATE;
process B: UPDATE users SET name = 'Peter' WHERE id = 1;

-- process B is completed without blocking because it does not change
-- the id field
```

## Safely Creating Related Records With Select for Share

A weaker form of `select for update` is the `select for share` query. It is
an ideal for ensuring referential integrity when creating child records for a
parent.

Let's use the users and purchases tables to demonstrate a use case for the
select for share query. Suppose that we want to create a new purchase for a
user. First, we would select the user from the database and then insert a new
record in the purchases database. Can we safely insert a new purchase into the
database? With a regular select statement we can't. Other processes could delete
the user in the moments between selecting the user and inserting the purchase.

One way to avoid potential issues is to query for the user with the `FOR SHARE`
locking clause.

``` sql
process A: BEGIN;
process A: SELECT * FROM users WHERE id = 1 FOR SHARE;

process B: DELETE FROM users WHERE id = 1;
-- process B blocks and must wait for process A to finish

process A: INSERT INTO purchases (id, user_id) VALUES (1, 1);
process A: COMMIT;

-- process B now unblocks and deletes the user
```

Select for share prevented other processes from deleting the user, but does not
prevent concurrent processes from selecting users. This is the major difference
between `select for share` and `select for update`.

The `select for share` prevents updates and deletes of rows, but doesn't prevent
other processes from acquiring a `select for share`. On the other hand,
`select for update` also blocks updates and deletes, but it also prevents other
processes from acquiring a `select for update` lock.

## The Select For No Key Updates and Select For Key Share

There are two more locking clauses in PostgreSQL introduces from version 9.3.
The `select for no key updates` and `select for key share`.

The `select for no key updates` behaves similarly to the `select for update`
locking clause but it does not block the `select for share`. It is ideal if you
are performing processing on the rows but don't want to block the creation of
child records.

The `select key share` is the weakest form of the with lock clause, and behaves
similarly to the `select for share` locking clause. It prevents the deletion of
the rows, but unlike `select for share` it does not prevent updates to the rows
that do not modify key values.

_Did you like this article? Or, do you maybe have a helpful hint to share? Please
leave it in the comment section bellow._
