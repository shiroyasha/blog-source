---
id: 388a832c-4b33-46c1-8429-e106235df900
title: Advisory Locks and How to Use Them
date: 2017-11-16
tags: programming, postgres
image: advisory-locks-and-how-to-use-them.jpg
---

PostgreSQL provides the means for creating locks with application defined
meaning. These locks are called *Advisory Locks* and are an ideal candidate for
concurrency control where the standard MVCC (multiversion concurrency control)
doesn't fit the bill. Advisory Locks can be the perfect tool in your arsenal
when you need to control access to a shared resource in a distributed system.

READMORE

![Enjoying advisory locking](/images/advisory-locks-and-how-to-use-them.jpg)

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

Like all locks in PostgreSQL, a complete list of advisory locks currently held
by any session can be found in the pg_locks system view.

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

Calling `SELECT pg_advisory_unlock_all()` will unlock all advisory locks
currently held by your session.

## Session and Transaction locks

There are two ways to acquire advisory locks in PostgreSQL, at session level or
at transaction level. Session level locks are held until the session ends or
until the lock is released manually. Transaction semantics are not honored for
session locks. A lock acquired in a transaction will hold even if the
transaction rollbacks. Transaction level advisory locks act like regular locks
and honor transaction semantics. A transactional advisory lock acquired in a
transaction will be released when the transaction ends.

In the previous section, we have acquired session level locks. To acquire a
transaction level advisory lock, an alternative transaction specific function
needs to be invoked.

``` sql
begin;

-- session level advisory lock
SELECT pg_try_advisory_lock(23);

-- transaction level advisory lock
SELECT pg_try_advisory_xact_lock(17);

SELECT mode, classid, objid FROM pg_locks WHERE locktype = 'advisory';

     mode      | classid | objid
---------------+---------+-------
 ExclusiveLock |       0 |    17
 ExclusiveLock |       0 |    23
(2 rows)

end;

-- after the transaction ends, only session level locks are held

SELECT mode, classid, objid FROM pg_locks WHERE locktype = 'advisory';

     mode      | classid | objid
---------------+---------+-------
 ExclusiveLock |       0 |    23
(1 row)
```

Both session and transaction level advisory locks can be acquired multiple times
by the owning process. Multiple lock requests stack, so that if the same resource
is locked three times it must then be unlocked three times to be released for
other sessions' use.

## Blocking and non-Blocking Acquiring Functions

There are two ways to acquire an advisory lock. With a blocking function that will
block and wait until the lock is available, or with a non-blocking function that will
return a boolean value signifying if the lock was acquired or not. In the previous
sections we have used the non-blocking versions of the function.

``` sql
-- non blocking version, returns true of false
SELECT pg_try_advisory_lock(123);

-- blocking version, wait for the lock to be available
SELECT pg_advisory_lock(123);
```

## Use Case for Advisory Locks in a System

Advisory locks are suitable for implementing various application-level
concurrency control mechanisms. For instance, advisory locks can be usable
for the following scenarios:

- we need to coordinate access to some shared resource or a 3rd party services
and we need to guarantee that only one node can access it at a time

- we want to calculate and send a report to some of our users, but we must
guarantee that background workers don't start the calculation concurrently

- a multi-node task scheduler can use advisory locks to coordinate task
distribution to workers

The benefit of using advisory locks for background processing for a given user
is that the tables are never actually locked for writing, so the main application
that executes the regular CRUD operations on the record can behave normally
and users will never notice anything is happening in the background.

As an example of using advisory locks, we will create a background looper task
in Ruby that processes our user's files on stored on S3.

First, let's define a Ruby module responsible for creating locks.

``` ruby
module LockManager
  def self.with_lock(number)
    lock = conn.select_value("select pg_try_advisory_lock(#{number});")

    return unless lock == 't'

    begin
      yield
    ensure
      conn.execute "select pg_advisory_unlock(#{number});"
    end
  end

  def conn
    ActiveRecord::Base.connection
  end
end
```

When we have a lock manager, we can implement a safe, concurrent friendly,
background processor.

``` ruby
loop do
  users = User.with_unprocessed_files.limit(100)

  users.each do |user|
    LockManager.with_lock(user.id) do
      content = fetch_file_from_s3(user.file)

      processed = process(content)

      upload_file_to_s3(user.file, processed)
    end
  end

  sleep 1
end
```

Finally, we can safely start several file processors on several nodes to do
our bidding.

An advisory note for the end. The above example is good entry point for constructing
such a system, but it is not bulletproof. For production use case, several other
concerns need to be addressed like connectivity issues to the database, handling
process and node crashes, resource starvation, and of course a good set of
metrics.

_Did you like this article? Or, do you maybe have a helpful hint to share? Please
leave it in the comment section bellow._
