---
id: 388a832c-4b33-46c1-8429-e106235df900
title: Advisory Locks and How to Use Them
date: 2017-11-13
tags: programming
image: 2017-11-13-advisory-locks-and-how-to-use-them.png
---

PostgreSQL provides the means for creating locks with application defined
meaning. These locks are called *Advisory Locks* and are an ideal candidate for
concurrency control where the standard MVCC (multiversion concurrency control)
doesn't fit the bill. Advisory Locks can be the perfect tool in your arsenal
when you need to control access to a shared resource in a distributed system.

![Enjoying advisory locking](https://upload.wikimedia.org/wikipedia/commons/5/5c/Gentlemen_in_conversation%2C_Eastern_Han_Dynasty.jpg)
