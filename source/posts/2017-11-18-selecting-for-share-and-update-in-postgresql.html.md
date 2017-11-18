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

``` text
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

The `SELECT ... FOR UPDATE` locks the rows just as a `FOR UPDATE` statement
would, and prevent any changes that could happen concurrently. The locks will be
released when the transaction ends.
