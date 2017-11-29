---
id: 00964f87-dd3c-4b29-8ecf-0e233ce586fa
title: Multi Version Concurrency Control
date: 2017-11-29
tags: programming
image: 2017-11-29-multiversion-concurrency-control.png
---

The most prominent feature of PostgreSQL is how it handles concurrency. Reads
never block writes, and writes never block reads. To achieve this, PostgreSQL
uses the Multi Version Concurrency Control (MVCC) model, an elegant solution for
a very hard problem. If you want to design highly concurrent applications, you
should really invest the time to understand the bits and bolts of this
mechanism.

![Multi Version Concurrency Control](images/2017-11-22-multiversion-concurrency-control.png)

This article explores how PostgreSQL handles concurrency with the Multi Version
Concurrency Control mechanism. We will discover the hidden system columns in
your database tables, the meaning of transaction ids, and the importance of
vacuuming your database.

## Reader and Writer Locks in the Database

A concurrency control model firstly need to operate correctly and to maintain
each transaction's integrity rules while transactions are running concurrently.
Correctness needs to be achieved with as good performance as possible.

In the beginning the most common concurrency control model in databases was
the two phase locking mechanism, that requires a shared lock while reading data
from a database table, and an exclusive lock when modifying data in the table.

For a quick recap, here is the boiled down purpose of the shared and exclusive
locks:

- A `shared lock` blocks _writers_, but allows other _readers_ to acquire it
- An `exclusive lock` blocks both _writers_ and _readers_

Waiting is the slowest form of concurrency control. If only one process can
access the data, it is pointless to buy ever bigger servers. For this reasons,
database systems are continuously improved to require as little locking as
possible, while maintaining correctness. Ideally, readers would not block
writers, and writers would not block readers.

One way to achieve a non-blocking behaviour for readers and writers, is to keep
track of _multiple versions of the same record_ and to limit their visibility
between transactions.

## Keeping Track of Multiple Versions of the Same Record

PostgreSQL uses the Multi Version Concurrency Control to allow fast reads and
writes in the database. It stores multiple rows in the table's data structure
itself and limits their visibility with the use `xmin` and `xmax` system
columns.

If you have never seen system columns in PostgreSQL, this is the perfect time to
test them. Choose any table in your database, and select the two columns.

``` sql
SELECT *, xmin, xmax FROM users;

 id | name  | xmin | xmax
----+-------+------+------
  1 | Peter | 1291 |    0
  2 | John  | 1292 | 1294

(2 rows)
```

To interpret the value in this column, you must know three things about
PostgreSQL:

- The `xmin` column stores the number of the transaction that inserted the value
- The `xmax` value storer the number of the transaction that deleted the record
- Transaction numbers are sequentially increased

Transaction numbers, or transaction ids, are a 32-bit integer in PostgreSQL.

A transaction in PostgreSQL can only see the committed tuple, if the `xmin` is
less than the number of the current transaction, and if `xmax` is greater then
the current transaction.

## MVCC and Data Modification in PostgreSQL

Let's cover the three basic modification statements in PostgreSQL with respect
to the MVCC concurrency model. We will first talk about insert, then about
delete, and finally about update which is actually a combination of insert and
delete in this concurrency model.

Insert is conceptually the simplest of the three operations. A new tuple is
created in the database, and the value will be visible to other transactions
once it was committed, given that we are using the default read committed
transaction isolation level.

``` sql
process A: BEGIN;
process A: SELECT txid_current();

txid_current
------------
          12

process A: INSERT INTO users (id, name) VALUES (1, "John");

process B: SELECT *, xmin, xmax FROM users;
 id | name | xmin | xmax
----+------+------+------
(0 rows)

process A: COMMIT;

process B: SELECT *, xmin, xmax FROM users;

 id | name | xmin | xmax
----+------+------+------
  1 | John |   12 |    0

-- xmin is set to the txid_current() of the transaction that inserted it
```

Delete is a bit more complicated. With the traditional two phase locking the
delete statement would lock and prevent readers from accessing the data. This is
not true if we are using multi version concurrency control.

``` sql
process A: BEGIN;
process A: SELECT txid_current();

txid_current
------------
          17

process A: DELETE FROM users WHERE id = 1;
-- this call would traditionally block all writters

process B: SELECT *, xmin, xmas FROM users;
 id | name | xmin | xmax
----+------+------+------
  1 | John |   12 |   17
(1 rows)

-- Process B (a reader) is not blocked. It sees an older
-- tuple in the database. Notice that xmax is already set by
-- the deleting transaction.

process A: COMMIT;

process B: SELECT * FROM users;
 id | name
----+-------
(0 rows)

-- after commit, process B can no longer see the transaction
```

When the transaction is committed that deletes the data, the data is only marked
for deletion but it isn't actually deleted from the database. With multi version
concurrency control deleting data immediately is not possible. There is always a
chance that an open transaction is still able to see the record.

For the actual deletion of data, a separate mechanism called `VACUUM` is
responsible for cleaning the values from the database. This process looks up
tuples that are no longer accessible to any transaction and deleted them. For
this reason, it is strongly advised to not disable database vacuuming in
PostgreSQL. Without vacuuming your database would only grow in size, and even
worse, you would eventually hit a transaction ID wraparound that can have
catastrophic consequences to your database.

Finally, we will cover the update action. This action is conceptually the same
as marking an old tuple for deletion and inserting a new tuple in the multi
version concurrency control model.

``` sql
process A: BEGIN;
process A: SELECT txid_current();

txid_current
------------
          23

process A: UPDATE users SET name = 'Marko' WHERE id = 1;
-- Traditionally, this would lock the record for reading.

process A: SELECT *, xmin, xmax FROM users;
 id | name  | xmin | xmax
----+-------+------+------
  1 | Marko |   23 |   0
(1 rows)

-- Process A creates a new tuple and sets the xmin to its transaction id

process B: SELECT *, xmin, xmax FROM users;
 id | name  | xmin | xmax
----+-------+------+------
  1 | John  |   17 |   23
(1 rows)

-- Process B still see the old tuple. Notice that this tuple has
-- its end of life set to Process A's transaction id.
```

With the update statement we can truly see the multi version concurrency control
in action. We have two different transactions that see two tuples for the same
record in the database. It feels like time travel. This is the true power of the
multi version concurrency control mechanism.

_Did you like this article? Or, do you maybe have a helpful hint to share? Please
leave it in the comment section bellow._
