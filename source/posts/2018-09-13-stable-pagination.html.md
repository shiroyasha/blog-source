---
id: 1b4b5b03-475c-4f67-ba4d-392ad2484ce0
title: Stable Pagination
date: 2018-09-13
tags: programming
image: 2018-09-13-stable-pagination.png
---

Stable Pagination
-----------------

Last week we've investigated a way to achieve stable pagination
for our new API. I've learned some new techniques for handling
pagination, and dig deep into the downsides of standard &mdash;
offset based &mdash; pagination.

Before I share our new approach, let's start with the exploring
the issues we wanted to solve. The most common pagination method
that APIs expose is the one that is based on offsets. The client
passes two information to the server: the desired page size, and
the page number. This is very convenient if your application is
backed by an SQL database, where you can almost directly inject
the passed arguments:

```
page_size = 10
page_number = 2

offset = page_size * page_number

SELECT * FROM posts
OFFSET $offset
LIMIT $page_size
ORDER BY created_at DESC
```

The issue arises when you want to visit the next page in the above example,
but someone inserted new records into the database in the
meantime. Then you can get some of the same results from the previous
example. Let's go through an example to demonstrate the issue:

```
# A client requests the first page

SELECT name FROM posts LIMIT 3 OFFSET 0 ORDER BY created_at DESC;

  post101
  post100
  post99

# Insertion of new records

INSERT (name) INTO posts VALUES (post102);
INSERT (name) INTO posts VALUES (post103);

# The client requests the second page

SELECT name FROM posts LIMIT 3 OFFSET 3 ORDER BY created_at DESC;

  post100 # I've seen this already!
  post99  # I've seen this already!
  post98  # This is new
```

Another issue is that `LIMIT <a> OFFSET <b>` doesn't scale for large
datasets. For large `OFFSET` values, the database still has to read all
the values from the disk and discard them until the goal is reached.
Implementing this kind of pagination for resources that have
high insertion frequency could cause you unwanted issues down the line.

To mitigate some of the previous issues we decided to use cursor based
pagination in our new API.

### Cursor Based Pagination

Cursor based pagination works by returning a pointer to specific record
in the database which will be used for subsequent requests. Let's see an
example to grasp the idea:

```
# First request from the client (page size=3)

SELECT id, name FROM posts LIMIT 4 ORDER BY created_at DESC;

                                 ^ ----- notice that we
                                         are requesting one more
                                         than requested

[101, post101] # we return this to the client
[100, post100] # we return this to the client
[ 99, post99 ] # we return this to the client
[ 98, post98 ] # <-- we use this to construct the next_page_token

 => response [post101, post100, post99], next_page_token=98


# Second request from the client (page_size=3, next_page_token=98)

SELECT id, name FROM posts
WHERE id < next_page_token
LIMIT 4
ORDER BY created_at DESC;

[ 98, post98 ] # we return this to the client
[ 97, post97 ] # we return this to the client
[ 96, post96 ] # we return this to the client
[ 95, post95 ] # <-- we use this to construct the next_page_token
```

Notice that with cursors we don't need to worry about insertions in
between the two requests. The pagination window is stable and we have
a precise pointer from which we will continue our pagination.

This approach will also scale much better for large datasets as the
database can utilize the index in the `WHERE id < next_page_token`.

The big trade-off that we had to accept is that our API can no longer
support jumps to a specific page, it needs to traverse there. For
our use case this is acceptable.

Another trade-off is that if you want to have stable pagination windows
you need to order your records by strictly increasing/decreasing value.

### Cursor based pagination with UUIDs for primary keys

The previous examples are simple, but they rely on the fact that ids
are incremental numbers. This wasn't the case for our use case as we
use UUIDs for primary keys almost exclusively in our tables.

The solution for this issues is to use the combination of two values
for constructing the next_page_token. The UUID that guarantees
uniqueness and created_at (for example) to guarantee increasing values.
Let's see an example:

```
# First request from the client (page size=3)

SELECT id, created_at, name FROM posts LIMIT 4 ORDER BY created_at DESC;

[ace9a01b-bcaa-471c-89a5-92da19b94f0c, 1536872459, post101]
[a84331fb-1d32-4fd9-9d9b-2420db87404d, 1536872448, post100]
[af98348d-34a4-4d1c-b026-21ef8edc7e2e, 1536872448, post99 ]
[aff9e8dc-b9bb-4c91-8ad8-e9055ffb7891, 1536872448, post98 ]

page_token = Base64("aff9e8dc-b9bb-4c91-8ad8-e9055ffb7891, 1536872448")

# Second request from the client (page_size=3)

SELECT id, name FROM posts
WHERE (uuid, created_at) < (page_token.id, page_token.created_at)
LIMIT 4
ORDER BY created_at DESC;

[bce9a01b-bcaa-471c-89a5-92da19b94f0c, 1536872458, post98]
[b84331fb-1d32-4fd9-9d9b-2420db87404d, 1536872448, post97]
[bf98348d-34a4-4d1c-b026-21ef8edc7e2e, 1536872448, post96]
[bff9e8dc-b9bb-4c91-8ad8-e9055ffb7891, 1536872441, post95]
```
