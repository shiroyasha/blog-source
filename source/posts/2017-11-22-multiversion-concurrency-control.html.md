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
