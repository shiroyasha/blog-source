---
id: fe965bdb-11a4-4d42-9472-0bed7a3de6ca
title: Deadlocks in PostgreSQL
date: 2017-11-30
tags: programming
image: 2017-11-30-deadlocks-in-postgresql.png
---

In concurrent systems where resources are locked, two or more processes can and
up in a state in which each process is waiting for the other one. This state is
called a deadlock. Deadlocks are an important issues that can happen in any
database and can be scary when you encounter them for the first time.

![Deadlocks in PostgreSQL](images/2017-11-30-deadlocks-in-postgresql.png)

In this article we will explore how deadlocks occur in PostgreSQL, what is the
deadlock timeout, and how to interpret the error raised by PostgreSQL in case of
a deadlock timeout.

##
