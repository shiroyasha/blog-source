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

Let's explore advisory locks, their use case, and how to use them from your
applications.

## Observing the Behaviour of Advisory Locks

I'm a strong believer in learning by doing, instead of only knowing the theory.
With that thought in mind, let's create a sandbox database for learning advisory
locks.

``` bash
$ createdb advisory-locks-db
```

Connect to the database:

```
$ psql -d advisory-locks-db
```

Now, when we have a test database, and an open connection to it, we are ready to
create our first advisory lock.

``` sql
SELECT pg_try_advisory_lock(10);
```

In the above session, we have created an advisory lock for the number `10`. To
acquire an advisory lock, you can pass any 64bit number to the function. This
is the essence of advisory locking. You are basically locking up a number in
the database, and your application needs to provide a meaning to that number.

Alternatively, instead of passing one 64bit to the function, you can pass two
32bit numbers to the function.

Let's create two advisory locks, and observe their presence in the pg_locks
system view:

``` sql
SELECT pg_try_advisory_lock(23);
SELECT pg_try_advisory_lock(112, 345);

SELECT mode, classid, objid FROM pg_locks WHERE locktype = 'advisory';

     mode      | classid | objid
---------------+---------+-------
 ExclusiveLock |     112 |   345
 ExclusiveLock |       0 |    23
(2 rows)
```

Finally, let's release the acquired locks:

``` sql
SELECT pg_advisory_unlock(23);
SELECT pg_advisory_unlock(112, 345);

SELECT mode, classid, objid FROM pg_locks WHERE locktype = 'advisory';

 mode | classid | objid
------+---------+-------
(0 rows)
```
