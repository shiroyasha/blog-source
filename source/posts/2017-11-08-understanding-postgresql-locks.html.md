---
id: 454b324c-cf4b-4559-9e82-11e042be13da
title: Understanding PostgreSQL locks
date: 2017-11-08
tags: programming
image: 2017-11-08-understanding-postgresql-locks.png
---

Locking is an important topic in any kind of database. Without properly handling
locks, an application might not only be slow, it might also be wrong and behave
in some insane ways. Therefor, learning proper locking techniques is essential
for good performance and correctness of our applications.

![](https://upload.wikimedia.org/wikipedia/commons/4/45/Blind_monks_examining_an_elephant.jpg)

Let's explore the types of locks available in PostgreSQL, when they are used,
and how to explore open locks in the system.

## Creating a basic lock in PostgreSQL

## Table level locks

## Row level locks

## Advisory Locks
