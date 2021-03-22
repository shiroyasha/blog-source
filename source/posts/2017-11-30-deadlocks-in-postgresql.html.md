---
id: fe965bdb-11a4-4d42-9472-0bed7a3de6ca
title: Deadlocks in PostgreSQL
date: 2017-11-30
tags: programming, postgres
image: 2017-11-30-deadlocks-in-postgresql.png
---

In concurrent systems where resources are locked, two or more processes can end
up in a state in which each process is waiting for the other one. This state is
called a deadlock. Deadlocks are an important issues that can happen in any
database and can be scary when you encounter them for the first time.

READMORE

![Deadlocks in PostgreSQL](images/2017-11-30-deadlocks-in-postgresql.png)

In this article we will explore how deadlocks occur in PostgreSQL, what is the
deadlock timeout, and how to interpret the error raised by PostgreSQL in case of
a deadlock timeout.

## Understanding How Deadlocks Occur in your Database

Before we dig into the details about deadlocks in PostgreSQL, it is important to
understand how they occur. Let's observe the following example where two
concurrent processes end up in a deadlock.

``` sql
process A: BEGIN;
process B: BEGIN;

process A: UPDATE users SET name = "Peter" WHERE id = 1;
process B: UPDATE users SET name = "Marko" WHERE id = 2;

-- Both process A and B acquired an exclusive lock in
-- their transactions. The lock will be released when
-- the transactions finishes.

process A: UPDATE users SET name = "John" WHERE id = 2;
-- process A tries to acquire an exclusive lock, but process B
-- already holds the lock for the record with id = 2
-- process A needs to wait till process B's transaction ends

process B: UPDATE users SET name = "John" WHERE id = 1;
-- process B tries to acquire an exclusive lock, but process A
-- already holds the lock for the record with id = 1
-- process B needs to wait till process A's transaction ends
```

At this point process A is waiting for process B, and process B is waiting for
process A. In other words, a deadlock has occurred. Neither of the two processes
can continue, and they will wait for each other indefinitely.

## The Deadlock Timeout

To resolve the situation from the previous example, PostgreSQL raises a deadlock
error if it detects that two processes are waiting for each other. PostgreSQL
will wait for a given interval before it raises the error. This interval is
defined with `deadlock_timeout` configuration value.

Here is output one of the process would see after the deadlock timeout passes:

``` sql
-- After a second, the deadlock timeout kicks in and raises an error

ERROR:  deadlock detected
DETAIL:  Process 12664 waits for ShareLock on transaction 1330;
         blocked by process 12588.
         Process 12588 waits for ShareLock on transaction 1331;
         blocked by process 12664.

HINT:  See server log for query details.
CONTEXT:  while updating tuple (0,31) in relation "users"
```

Rollbacks are of course not ideal, but they are a better solution than waiting
forever. If possible you should strive to design your application in a way that
prevents deadlocks in the first place. For example, if you are locking tables in
your application, you want to make sure that you always invoke the locking in
the same order.

In general, applications must be ready to handle deadlocks issue and retry the
transaction in case of a failure.

The best defense against deadlocks is generally to avoid them by being certain
that all applications using a database acquire locks on multiple objects in a
consistent order.

## Adjusting the Deadlock Timeout

The deadlock timeout is the amount of time that PostgreSQL waits on a lock
before it checks for a deadlock. The deadlock check is an expensive operation so
it is not run every time a lock needs to wait. Deadlocks should not be common in
production environments and PostgreSQL will wait for a while before running the
expensive deadlock check.

The default timeout value in PostgreSQL is 1 second, and this is probably the
smallest time interval you would want to set in practice. If your database is
heavily loaded, you might want to raise this value to reduce the overhead on
your database servers.

Ideally, the deadlock_timeout should be a bit longer than your typical
transaction duration.

_Did you like this article? Or, do you maybe have a helpful hint to share? Please
leave it in the comment section bellow._
