---
id: fe965bdb-11a4-4d42-9472-0bed7a3de6ca
title: Deadlocks in PostgreSQL
date: 2017-11-30
tags: programming
image: 2017-11-30-deadlocks-in-postgresql.png
---

The most prominent feature of PostgreSQL is how it handles concurrency. Reads
never block writes, and writes never block reads. To achieve this, PostgreSQL
uses the Multi Version Concurrency Control (MVCC) model, an elegant solution for
a very hard problem. If you want to design highly concurrent applications, you
should really invest the time to understand the bits and bolts of this
mechanism.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Pasive_but_Alert_-_Elephant_Seals_-_panoramio.jpg/640px-Pasive_but_Alert_-_Elephant_Seals_-_panoramio.jpg)
