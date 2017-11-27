---
id: 00964f87-dd3c-4b29-8ecf-0e233ce586fa
title: Multi Version Concurrency Control
date: 2017-11-22
tags: programming
image: 2017-11-22-multiversion-concurrency-control.png
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

- A `shared lock` blocks _writers_, but allows other _readers_ to acquire the same lock
- An `exclusive lock` blocks both _writers_ and _readers_

Waiting is the slowest form of concurrency control. If only one process can
access the data, it is pointless to buy ever bigger servers. For this reasons,
database systems are continuously improved to require as little locking as
possible, while maintaining correctness. Ideally, readers would not block
writers, and writers would not block readers.

One way to achieve a non-blocking behaviour for readers and writers, is to keep
track of _multiple versions of the same record_ and to limit their visibility
between transactions.

## How PostgreSQL Keeps Track of Multiple Versions of the Same Record

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

A transaction in PostgreSQL can only see the record, if the `xmin` is less than
the number of the current transaction, and if `xmax` is greater then the current
transaction.

## Multi Version Concurrency Control and Data Modification in PostgreSQL

