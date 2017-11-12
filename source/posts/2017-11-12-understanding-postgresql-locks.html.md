---
id: 454b324c-cf4b-4559-9e82-11e042be13da
title: Understanding PostgreSQL locks
date: 2017-11-12
tags: programming
image: 2017-11-12-understanding-postgresql-locks.png
---

Locking is an important topic in any kind of database. Without properly handling
locks, an application might not only be slow, it might also be wrong and behave
in some insane ways. Therefore, learning proper locking techniques is essential
for good performance and correctness of our applications.

![Blind Monks Examining an Elephant](images/2017-11-12-understanding-postgresql-locks.png)

Let's explore the types of locks available in PostgreSQL, when they are used,
and how to explore open locks in the system.

## Setting up a sandbox environment

I strongly believe that in order to learn something, you need to try it out with
your own hands. Following that thought, here is an easy way to set up a sandbox
environment for PostgreSQL testing.

Start by creating a test database a connect to it via `psql`:

``` bash
$ createdb test-db-001

$ psql -d test-db-001
psql (10.0)
Type "help" for help.

test-db-001=#
```

In the database, create a `users` table with several records:

``` sql
test-db-001=# CREATE TABLE users (id int, username text);
CREATE TABLE

test-db-001=# INSERT INTO users (id, username)
test-db-001=# VALUES (1, 'igor'), (2, 'bob'), (3, 'john'), (4, 'susan');
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

I find a user table the best table for doing exercises, as it a relation that
you will encounter in most most web applications.

Quit the connection to the database:

``` sql
test-db-001=# \q
```

## Test environment for learning about PostgreSQL locks

We will start two parallel connections to the database, one for starting and
stopping transactions, and the other one for observing and listing locks that
are created.

For the sake of simplicity, we will call these two connection Alice and Bob. Bob
will create transactions and locks, while Alice will be our administrator that
observes the state of the database.

Open two parallel terminal windows. In the first terminal, start a `psql`
session a change the name of the prompt to `bob`:

``` sql
$ psql -d test-db-001
psql (10.0)
Type "help" for help.

test-db-001=# \set PROMPT1 '(bob) # '
(bob) #
```

In the second terminal window, open a new `psql` session and name it `alice`:

``` sql
$ psql -d test-db-001
psql (10.0)
Type "help" for help.

test-db-001=# \set PROMPT1 '(alice) # '
(alice) #
```

Everything is set up. We are ready to explore.

## Exploring the pg_locks view

The `pg_locks` view provides access to information about the locks held by open
transactions within the database server.

Alice, our administrator, will start by describing the `pg_locks` view and
listing the available columns.

``` sql
(alice) # \d pg_locks;
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

Let's look into open locks in the database with the `select` command:

``` sql
(alice) # SELECT locktype, relation, mode, pid FROM pg_locks;

  locktype  | relation |      mode       |  pid
------------+----------+-----------------+-------
 relation   |    11577 | AccessShareLock | 16524
 virtualxid |          | ExclusiveLock   | 16524

(2 rows)
```

The `11577` relation is not descriptive enough. We will use `::regclass` to cast
the number to the name of the relation:

``` sql
(alice) # SELECT locktype, relation::regclass, mode, pid FROM pg_locks;

  locktype  | relation |      mode       |  pid
------------+----------+-----------------+-------
 relation   | pg_locks | AccessShareLock | 16524
 virtualxid |          | ExclusiveLock   | 16524

(2 rows)
```

This is clearer. The open lock in the database is the result of the `select`
statement that lists the locks. Let's filter that lock out of the resulting
list:

``` sql
(alice) # SELECT locktype, relation::regclass, mode, pid
(alice) # FROM pg_locks WHERE pid != pg_backend_pid();

 locktype | relation | mode | pid
----------+----------+------+-----
(0 rows)

(alice) #
```

We used the `pg_backend_pid()` to filter out all locks that are created from
Alice's session. With that change, we can see that there are no open locks in
the database.

## Exploring lock modes

Bob, our user, steps in to the game. He will open some transactions to help us
to learn about the various lock modes.

Bob will now open a transaction with `BEGIN`, and select all users. However, he
will not close the transaction. This will help Alice to look into the lock that
is implicitly created with Bob's `SELECT` statement.

``` sql
(bob) # BEGIN;
(bob) # SELECT * FROM users;
```

Alice now sweeps in and lists the locks:

``` sql
(alice) # select locktype, relation::regclass, mode
(alice) # FROM pg_locks WHERE pid != pg_backend_pid();

  locktype  | relation |      mode
------------+----------+-----------------
 relation   | users    | AccessShareLock
 virtualxid |          | ExclusiveLock

(2 rows)
```

The `SELECT` statement creates a *AccessShareLock*. This is type of lock that is
generally created by queries that *read* a table but do not *modify* it.

The *AccessShareLock* conflicts with the *AccessExclusiveLock*. That means that
if another transactions puts a *AccessExclusiveLock* lock on the table, select
statements will not work.

Bob will now end the open transaction, releasing the lock, and he will try to
acquire a *AccessExclusiveLock* for the user table. Adding a new column to the
table does just that, it locks up the table with exclusive access.

``` sql
(bob) # END;

(bob) # BEGIN;
(bob) # ALTER TABLE users ADD age int;
```

``` sql
(alice) # SELECT locktype, relation::regclass, mode, pid
(alice) # FROM pg_locks WHERE pid != pg_backend_pid();

   locktype    | relation |        mode         |  pid
---------------+----------+---------------------+-------
 virtualxid    |          | ExclusiveLock       | 16537
 transactionid |          | ExclusiveLock       | 16537
 relation      | users    | AccessExclusiveLock | 16537
(3 rows)

(alice) #
```

What happens if Alice tries to list the content of the `users` table at this
moment?

``` sql
(alice) # SELECT * FROM users;
```

The command never finishes. It waits for Bob's *AccessExclusiveLock* to be
released. We can hit `CTRL+C` to cancel the select statement:

``` sql
(alice) # SELECT * FROM users;
^CCancel request sent
ERROR:  canceling statement due to user request
```

Let's also stop Bob's `ALTER TABLE` statement:

``` sql
(bob) # ROLLBACK;
```

## Lock Modes in PostgreSQL

We have learned about two locks modes so far. The `AccessShareLock` that is
created for read queries like the `select` statements, and `AccessExclusiveLock`
that is created for operations that modify the whole table.

There are several more lock modes in PostgreSQL.

**ACCESS SHARE** — Acquired by queries that only read from a table but do not
modify it. Typically, this is a *select* query.

**ROW SHARE** — Acquired by the *SELECT FOR UPDATE* and *SELECT FOR SHARE* queries.

**ROW EXCLUSIVE** — Acquired by queries that modify the data in a table.
Typically, *update*, *delete*, and *insert* queries.

**SHARE UPDATE EXCLUSIVE** — Acquired by *vacuum*, concurrent indexes, statistics,
and some variants of the *alter table* commands.  This mode protects a table
against concurrent schema changes and *vacuum* runs.

**SHARE** — Acquired by *create index* that is not executed in concurrent mode.
This mode protects a table against concurrent data changes.

**SHARE ROW EXCLUSIVE** — This mode protects a table against concurrent data
changes, and is self-exclusive so that only one session can hold it at a time.
Acquired by *create collation*, *create trigger*, and many forms of *alter table*.

**EXCLUSIVE** — This mode allows only concurrent ACCESS SHARE locks, i.e., only
reads from the table can proceed in parallel with a transaction holding this
lock mode.

**ACCESS EXCLUSIVE** — This mode guarantees that the holder is the only
transaction accessing the table in any way. Acquired by *DROP TABLE*, *ALTER
TABLE*, *VACUUM FULl* commands.

## Explicit locking

In the previous sections, we have learned that all of the typical SQL commands
acquire some sort of lock implicitly. We can also acquire locks explicitly with
the `WITH LOCK` statement.

Let's observe Bob as he acquires an explicit lock.

``` sql
(bob) # begin;
(bob) # LOCK TABLE users;
```

When Alice lists open locks we will see that an *AccessExclusiveLock* lock was
acquired for the users table. This is the default for the `LOCK TABLE`
statement.

``` sql
(alice) # SELECT locktype, relation::regclass, mode, pid
(alice) # FROM pg_locks WHERE pid != pg_backend_pid();

   locktype    | relation |        mode         |  pid
---------------+----------+---------------------+-------
 virtualxid    |          | ExclusiveLock       | 22546
 relation      | users    | AccessExclusiveLock | 22546
 transactionid |          | ExclusiveLock       | 22546
(3 rows)
```

Bob can acquire any lock mode with the `WITH LOCK` statement. For example, to
acquire with a *Share Update Exclusive* mode he would enter:

``` sql
(bob) # LOCK TABLE users IN SHARE UPDATE EXCLUSIVE MODE;
```

The locks are granted until the transaction ends.

*Did you like this article? Or, do you maybe have a helpful hint to share?
Please leave it in the comment section bellow.*
