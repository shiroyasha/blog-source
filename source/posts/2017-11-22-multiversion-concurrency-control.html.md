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
- An `exclusive lock` blocks both data _writers_ and _readers_

Waiting is the slowest form of concurrency control. If only one process can
access the data, it is pointless to buy ever bigger servers. For this reasons,
database systems are continuously improved to require as little locking as
possible, while maintaining correctness. Ideally, readers would not block
writers, and writers would not block readers.

One way to achieve a non-blocking behaviour for readers and writers, is to keep
track of _multiple versions of the same record_ and to limit their visibility
between transactions.
