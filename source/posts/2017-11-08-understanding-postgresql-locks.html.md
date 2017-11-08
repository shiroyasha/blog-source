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

``` bash
$ createdb test-db-001
$ psql -d test-db-001
psql (10.0)
Type "help" for help.

test-db-001=#
```

``` sql
test-db-001=# CREATE TABLE users (id int, username text);
CREATE TABLE

test-db-001=# INSERT INTO users (id, username) VALUES (1, 'igor'), (2, 'bob'), (3, 'john'), (4, 'susan');
INSERT 0 4

test-db-001=# SELECT * FROM users;
 id | username
----+----------
  1 | igor
  2 | bob
  3 | john
  4 | susan
(4 rows)
```

``` sql
test-db-001=# \set PROMPT1 '(bob) %/%R%# '
(bob) test-db-001=#
```

``` sql
test-db-001=# \set PROMPT1 '(alice) %/%R%# '
(alice) test-db-001=#
```

``` sql
(bob) # \d pg_locks;
                   View "pg_catalog.pg_locks"
       Column       |   Type   | Collation | Nullable | Default
--------------------+----------+-----------+----------+---------
 locktype           | text     |           |          |
 database           | oid      |           |          |
 relation           | oid      |           |          |
 page               | integer  |           |          |
 tuple              | smallint |           |          |
 virtualxid         | text     |           |          |
 transactionid      | xid      |           |          |
 classid            | oid      |           |          |
 objid              | oid      |           |          |
 objsubid           | smallint |           |          |
 virtualtransaction | text     |           |          |
 pid                | integer  |           |          |
 mode               | text     |           |          |
 granted            | boolean  |           |          |
 fastpath           | boolean  |           |          |
```

``` sql
(alice) # BEGIN;
(alice) # SELECT * FROM users;
```

``` sql
(bob) # select locktype, relation::regclass, mode from pg_locks WHERE pid != pg_backend_pid();

  locktype  | relation |      mode
------------+----------+-----------------
 relation   | users    | AccessShareLock
 virtualxid |          | ExclusiveLock

(2 rows)
```

``` sql
(alice) # BEGIN;
(alice) # UPDATE users SET id = 5 WHERE username = 'igor';
```

``` sql
(bob) # select locktype, relation::regclass, mode from pg_locks WHERE pid != pg_backend_pid();

   locktype    | relation |       mode
---------------+----------+------------------
 relation      | users    | RowExclusiveLock
 virtualxid    |          | ExclusiveLock
 transactionid |          | ExclusiveLock

(3 rows)
```



## Table level locks

## Row level locks

## Advisory Locks
