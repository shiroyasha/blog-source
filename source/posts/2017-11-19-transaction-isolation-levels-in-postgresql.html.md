---
id: dc001f2c-fe99-4303-b127-32f8ab9b2abd
title: Transaction Isolation Levels in PostgreSQL
date: 2017-11-19
tags: programming
image: 2017-11-19-transaction-isolation-levels-in-postgresql.jpg
---

Misunderstanding transaction isolation levels can lead to disgusting side
effects in your application. Debugging such issues can be more than painful. The
SQL standard defines four levels of transaction isolation. Each of these
isolation levels defines what happens if two concurrent processes try to read
data updated by other processes.

![Transaction Isolation Level in PostgreSQL](2017-11-19-transaction-isolation-levels-in-postgresql.jpg)

This article explores how PostgreSQL isolates your transactions by default, and
explains the alternative options you can take to ensure the correctness of your
data. We will also explore the performance cost of the various isolation levels,
and the typical use case for each of them.

## The Isolation of Concurrent Transactions

Before we dig into the theoretical explanation, let's observe the default
behaviour of PostgreSQL transactions. We want to explore what happens if two
concurrent process access the same values in the database. Are the two
transactions totally isolated from each other?

``` sql
process A: begin;

process A: SELECT sum(value) FROM purchases;
--- process A sees that the sum is 1600

process B: INSERT INTO purchases (value) VALUES (400)
--- process B inserts a new row into the table while
--- process A's transaction is in progress

process A: SELECT sum(value) FROM purchases;
--- process A sees that the sum is 2000

process A: COMMIT;
```

By default, transactions in SQL are isolated with the Read Committed isolation
level. Two successive select commands can return different data in the same
transaction. In the above example, process A first calculated the sum 1600, and
then after the process B made changes, it calculated a different value of 2000.

Most developers would actually expect the two select queries to return the same
value in a single transaction. This is not true, and can lead to bizarre bugs if
the developers don't expect changes during transactions.

## The Four Isolation Levels in the SQL standard

The SQL standard defines four different isolation levels for transactions. The
most strict isolation level is Serializable, while the three other isolation
levels are defined in terms of effects that are allowed to happen when running
transactions concurrently.

- The `Serializable` isolation level guarantees that concurrent transactions run
as they would if you would run sequentially one by one in order.

- One step weaker is the `Read Reputable` isolation level that allows _Phantom
Reads_ to happen in the transaction. Contrary to transactions running in the
Serializable mode, the set of rows that is returned by two consecutive select
queries in a transaction can differ. This can happen if another transaction adds
or removes rows from the table we are querying.

- Even weaker is the `Read Commited` isolation level. Two consecutive select
statements in a transaction can return different data. Contrary to the *Read
Repeatable* level, this level allows not only the set of rows to change, but also
the data that those rows contain. This can happen if another transaction
modifies the rows.

- The weakest isolation level is `Read Uncommitted` where dirty reads can occur.
That means that non-committed changes from other transactions can affect a
transaction.

The last isolation level `Read Uncommited` is not supported in PostgreSQL. If
you request this isolation model, PostgreSQL will use `Read Commited` instead.

## Comparing Read Committed with Read Repeatable Isolation

I strongly believe in learning by doing. A real world example will help us to
truly grasp the differences in these isolation levels. Let's explore the
transaction levels and observe the side effects.

First, we will repeat the example from the first section, with the default read
committed isolation level.

``` sql
process A: BEGIN; -- the default is READ COMMITED

process A: SELECT sum(value) FROM purchases;
--- process A sees that the sum is 1600

process B: INSERT INTO purchases (value) VALUES (400)
--- process B inserts a new row into the table while
--- process A's transaction is in progress

process A: SELECT sum(value) FROM purchases;
--- process A sees that the sum is 2000

process A: COMMIT;
```

If we want to avoid the changing sum value in process A during the lifespan of
the transaction, we can use the reputable read transaction mode.

``` sql
process A: BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

process A: SELECT sum(value) FROM purchases;
--- process A sees that the sum is 1600

process B: INSERT INTO purchases (value) VALUES (400)
--- process B inserts a new row into the table while
--- process A's transaction is in progress

process A: SELECT sum(value) FROM purchases;
--- process A still sees that the sum is 1600

process A: COMMIT;
```

The transaction in process A fill freeze its snapshot of the data and offer
consistent values during the life of the transaction.

Reputable reads are not more expensive than the default read commit transaction.
There is no need to worry about performance penalties. However, applications
must be prepared to retry transactions due to serialization failures.

Let's observe an issue that can occur while using the repeatable read isolation
level — the `could not serialize access due to concurrent update` error.

``` sql
process A: BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

process B: BEGIN;
process B: UPDATE purchases SET value = 500 WHERE id = 1;

process A: UPDATE purchases SET value = 600 WHERE id = 1;
-- process A wants to update the value while process B is changing it
-- process A is blocked until process B commits

process B: COMMIT;
process A: ERROR:  could not serialize access due to concurrent update

-- process A immidiatly errors out when process B commits
```

If process B would rolls back, then its changes are negated and repeatable read
can proceed without issues. However, if process B commits the changes then the
repeatable read transaction will be rolled back with the error message because
it can not modify or lock the rows changed by other processes after the
repeatable read transaction has began.

## Read Repeatable vs. Serializable Isolation Level

The Serializable isolation level offers the strictest isolation. The idea behind
Serializable transaction is simple. If a transaction is known to be working
correctly when there is only one process in the system, then it should work
correctly when there are many processes in the system.

This guarantee comes with a price. Serializable transaction error out with
Serializable issues frequently, and there is an additional performance cost to
be paid. I would advise using Serializable transaction only if you have a deep
understanding of the PostgreSQL engine.

The SQL standard allows Phantom Reads — concurrent processes can affect the
number of rows returned by a select statement — but in PostgreSQL this is not
true. PostgreSQL protects even from phantom reads in the Read Reputable
isolation mode.

You might be wondering what is the difference between Serializable and Reputable
Reads in PostgreSQL. Let's compare a two examples that demonstrate the
differences between the two isolation modes.

``` sql
process A: BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
process A: SELECT sum(value) FROM purchases;
process A: INSERT INTO purchases (value) VALUES (100);

process B: BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
process B: SELECT sum(value) FROM purchases;
process B: INSERT INTO purchases (id, value);
process B: COMMIT;

process A: COMMIT;
```

With Repeatable Reads everything works, but if we run the same thing with a
Serializable isolation mode, process A will error out.

``` sql
process A: BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
process A: SELECT sum(value) FROM purchases;
process A: INSERT INTO purchases (value) VALUES (100);

process B: BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
process B: SELECT sum(value) FROM purchases;
process B: INSERT INTO purchases (id, value);
process B: COMMIT;

process A: COMMIT;

ERROR: could not serialize access due to read/write
dependencies among transactions

DETAIL: Reason code: Canceled on identification as
a pivot, during commit attempt.

HINT: The transaction might succeed if retried.
```

Both transactions have modified what the other transaction would have read in
the select statements. If both would allow to commit this would violate the
Serializable behaviour, because if they were run one at a time, one of the
transactions would have seen the new record inserted by the other transaction.

Did you like this article? Or, do you maybe have a helpful hint to share? Please
leave it in the comment section bellow.
