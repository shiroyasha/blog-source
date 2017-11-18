---
id: 6199153d-d06e-4b3a-a14f-e69c87ed59d9
title: Selecting for Share and Update in PostgreSQL
date: 2017-11-18
tags: programming
image: 2017-11-18-selecting-for-share-and-update-in-postgresql.png
---

A regular select statement does not give you enough protection if you want to
query data and make a change in the database related to it. Other transactions
can update or delete the data you just queried. PostgreSQL offers two additional
select statements that lock on read and provide an extra layer of safety.

![Selecting for Share and Update](http://maxpixel.freegreatpicture.com/static/photo/640/Namibia-Elephant-African-Bush-Elephant-Africa-84186.jpg)
