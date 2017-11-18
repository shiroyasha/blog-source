---
id: 6199153d-d06e-4b3a-a14f-e69c87ed59d9
title: Selecting for Share and Update in PostgreSQL
date: 2017-11-18
tags: programming
image: 2017-11-18-selecting-for-share-and-update-in-postgresql.png
---

A regular select statement does not give you enough protection if you want to
query data and make a change in the database related to it. Other transactions
can update or delete the data you just queried. PostgreSQL offers additional
select statements that lock on read and provide an extra layer of safety.

![Selecting for Share and Update](http://maxpixel.freegreatpicture.com/static/photo/640/Namibia-Elephant-African-Bush-Elephant-Africa-84186.jpg)

This article explores the `select for share` and `select for update` statements,
the locks that are created with these statements, and the use cases for using
these two select statements.

## Safely Updating Data

Sometimes, applications read some data from the database, process the data, and
save the result back in the database. This is a classic example where the
`select for update` can provide additional safety.

Let's consider the following example:

``` sql
BEGIN;
SELECT * FROM purchases WHERE processed = false;

-- * application is now processing the purchases *

UPDATE purchases SET ...;
COMMIT;
```

The above code snippet can be victim of a nasty race condition. The problem is
that some other part of the application can update some of the unprocessed data.
Changes to those rows will be then overwritten when the data processing
finishes.

Here is an example scenario in which the data suffers from an intrusive race
condition.

``` sql
process A: SELECT * FROM purchases WHERE processed = false;

--- process B updates the data while process A is processing it
process B: SELECT * FROM purchases;
process B: UPDATE purchases SET ...;

process A: UPDATE purchases SET ...;
```

To mitigate this issue, we can _select the data for updating_. Here is an
example how we would do it:

``` sql
BEGIN;
SELECT * FROM purchases WHERE processed = false FOR UPDATE;

-- * application is now processing the purchases *

UPDATE purchases SET ...;
COMMIT;
```

The `select ... for update` acquires a `ROW SHARE LOCK` on the table. This lock
conflicts with the `EXCLUSIVE` lock needed for an `update` statement, and
prevents any changes that could happen concurrently. The locks will be released
when the transaction ends.

``` sql
process A: SELECT * FROM purchases WHERE processed = false FOR UPDATE;
process B: SELECT * FROM purchases FOR UDPATE;
--- process B blocks blocks and waits process A to finish

process A: UPDATE purchases SET ...;
process B: UPDATE purchases SET ...;
```

## Non-blocking Select for Update Statements

When the applications selects some rows for update, other processes are forced
to wait for the transaction to end before they can get a hold of that lock. By
default this waiting is a blocking call.

If the processing takes too long to complete, for whatever reason, we can use
the `select ... for update nowait` statement to prevent blocking calls to our
database. This query will error out if the rows are not available for selection.

``` sql
process A: SELECT * FROM purchases WHERE processed = false;

--- process B tries to select the data, but fails
process B: SELECT * FROM purchases FOR UPDATE NOWAIT;
process B: ERROR could not obtain lock on row in relation "purchases"

process A: UPDATE purchases SET ...;
```

## Processing Non-Locked Database Rows

Select for update can be rigid lock on your table. Concurrent processes can be
blocked and starved out. Waiting is the slowest for of concurrent processing.
If only one CPU can be active at a time, it is pointless to vertically scale
your servers. For this purpose, in PostgreSQL there is a mechanism for selecting
only rows that are not locked.

The `select ... for update skip locked` is a statement that allows you to query
rows that have no locks. Let's observe the following scenario to grasp its use
case:

``` sql
process A: SELECT * FROM purchases
process A:   WHERE processed = false FOR UPDATE SKIP LOCKED;

process B: SELECT * FROM purchases
process B:   WHERE created_at < now()::date - interval '1w';
process B:   FOR UPDATE SKIP LOCKED;

-- process A selects and locks all unprocess rows
-- process B selects all non locked purchases older than a week

process A: UPDATE purchases SET ...;
process B: UPDATE purchases SET ...;
```

Both Process A and Process B can process data concurrently.
