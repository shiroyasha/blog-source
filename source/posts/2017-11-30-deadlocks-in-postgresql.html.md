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

To resolve this situation PostgreSQL has a deadlock timeout that raises an error
if a deadlock occurs. Here is output one of the process would see after the
deadlock timeout passes:

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

## Debugging the Deadlock Error Message

