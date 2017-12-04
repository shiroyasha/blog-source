---
id: f7c883cc-e3db-4238-8a44-c3d68ff1e291
title: The PostgreSQL Query Cost Model
date: 2017-12-03
tags: programming
image: 2017-12-03-the-postgresql-query-cost-model.png
---

Slow database queries harm your organization in many ways. They can damage the
reputation of otherwise great applications, make background processing painfully
slow, and drastically increase the cost of your infrastructure. As a seasoned
web developer, it is absolutely essential to learn about optimization strategies
for your data layer.

READMORE

![The PostgreSQL Query Cost Model](images/2017-12-03-the-postgresql-query-cost-model.png)

In this article we will explore the cost model of PostgreSQL, how to understand
the output of the `explain` command, and most importantly, how to use the data
to improve the throughput of your applications.

## Making Use of the Explain PostgreSQL Command

Before deploying a new query in your application, it is a good practice to run
it through the `explain` command in PostgreSQL to get an estimate of the
performance impact that the new query will have on your system.

We'll start with an example database table to illustrate the usage of `explain`.
This table will have a million records.

``` sql
db # CREATE TABLE users (id serial, name varchar);

db # INSERT INTO users (name) SELECT 'John'
     FROM generate_series(1, 1000000);

db # SELECT count(*) FROM users;
  count
---------
 1000000
(1 row)

db # SELECT id, name FROM users LIMIT 10;
 id | name
----+------
  1 | John
  2 | John
  3 | John
  4 | John
  5 | John
  6 | John
  7 | John
  8 | John
  9 | John
 10 | John
(10 rows)
```

Suppose we need to look up a user with a given id, but before we deploy the new
code we want to estimate the cost of that operation. Let's run an explain cause
with our desired query:

``` sql
db # explain select * from users where id = 870123;

                               QUERY PLAN
------------------------------------------------------------------------
 Gather  (cost=1000.00..11614.43 rows=1 width=9)
   Workers Planned: 2
   ->  Parallel Seq Scan on users  (cost=0.00..10614.33 rows=1 width=9)
         Filter: (id = 870123)

(4 rows)
```

There is a lot of output in the above example, but we can get the gist of it. To
run this query, PostgreSQL plans to fire up two parallel workers. Each worker
will run sequential scan on the table, and finally, the gatherer will merge the
results from the two workers.

In this article, we will focus on the `cost` in the above output and how
PostgreSQL calculates it.

To simplify our cost exploration, let's run the above query, but limit the
number of parallel workers to 0.

``` sql
db # SET max_parallel_workers_per_gather = 0;

db # explain select * from users where id = 870123;

                       QUERY PLAN
---------------------------------------------------------
 Seq Scan on users  (cost=0.00..17906.00 rows=1 width=9)
   Filter: (id = 870123)

(2 rows)
```

This is a bit simpler. With only one CPU core, the estimated cost is `17906`.

## The Math Behind The Cost Value

The cost, or penalty points, is mostly an abstract concept in PostgreSQL. There
are many ways in which PostgreSQL can execute a query, and PostgreSQL always
chooses the execution plan with the lowest possible cost value.

The calculate the cost, PostgreSQL first looks at the size of your table in
bytes. Let's find out the size of the users table.

``` sql
db # select pg_relation_size('users');

 pg_relation_size
------------------
         44285952
(1 row)
```

PostgreSQL will add cost points to for each block it has to read sequentially.
If we know that each block consists of `8kb` we can calculate the cost value for
the sequential block read from our table.

``` ruby
block_size = 8192 # block size in bytes
relation_size = 44285952

blocks = relation_size / block_size # => 5406
```

Now, that we know the number of block, let's find out how many points will
PostgreSQL allocate for each block read.

``` sql
db # SHOW seq_page_cost;

 seq_page_cost
---------------
 1

(1 row)
```

In other words, PostgreSQL allocates one cost point for each block. That gives
`5406` cost points to read the values from the table.

Reading values from the disk is not everything that PostgreSQL needs to do. It
has to send those values to the CPU and to apply a `WHERE` filter. Two values
are interesting for this calculation.

``` sql
db # SHOW cpu_tuple_cost;

 cpu_tuple_cost
----------------
  0.01

db # SHOW cpu_operator_cost;

 cpu_operator_cost
-------------------
  0.0025
```

Now, we have all the values to calculate the value that we got in our `explain`
clause.

``` ruby
number_of_records = 1000000

block_size    = 8192     # block size in bytes
relation_size = 44285952

blocks = relation_size / block_size # => 5406

seq_page_cost   = 1
cpu_tuple_cost  = 1
cpu_filter_cost = 1

cost = blocks * seq_page_cost +
       number_of_records * cpu_tuple_cost +
       number_of_records * cpu_filter_cost

cost # => 17546
```

## Indexes and The PostgreSQL Cost Model

Indexing is and will most probably remain the most important topic in a life of
a database engineer. Does adding an index reduces the cost of our select
statements? Let's find out.

``` sql
db #
```
