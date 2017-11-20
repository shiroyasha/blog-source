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

process A: SELECT sum(value) from purchases;
--- process A sees that the sum is 1600

process B: INSERT INTO purchases (value) VALUES (400)
--- process B inserts a new row into the table while
--- process A's transaction is in progress

process A: SELECT sum(value) from purchases;
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

## Reputable Reads in a Transaction

## Serializable transaction
