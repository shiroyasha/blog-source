---
id: 6e3f2cc4-adca-49db-97cb-f07a6039cdf0
title: "Intimate connections: Sharing a database"
date: 2017-07-19
tags: hidden
image: shared-databases.png
---

Your monolith was slowing you down, and you have decided that it is time to
invest in a multiple service based approach. There were lot of new things to
learn, but finally, you are free to experiment with new technologies. Your
services can be developed & deployed independently. Life is good.

READMORE

However, your monolith is still here. It still manages the majority of your
data. You quickly notice that it is hard to extend your system without gaining
access to your main database. Without solving this issue, you can't develop any
meaningful new service in your system.

There is a quick & dirty solution. You can share your database with your
microservices. Why not push it even farther, all of our services can share a
database. What can go wrong?

![Sharing a database between multiple services](images/shared-databases.png)

### Too much intimacy?

Loosely coupled components that communicate only through a public API have many
benefits. Most importantly, they allow you to change the internals of one
component without affecting the rest of the system.

If you are not making changes in the public interface, you are free to build,
improve, and deploy your service independently from the rest of the system. This
alone is a huge benefit, as it reduces the pressure on your developers to
constantly keep in mind all the intricate ways in which two components can be
connected.

For this reason, public interfaces should be as small as possible. If you are
exposing every little implementation detail, every other service can rightfully
use it and depend on it.

Now consider two services that share a database. I would argue that the
database schema is one huge public interfaces between the services. Now, if you
want to change anything in your database, you need to double check with any
other service that might be using a database column that you are about to remove.

Repeat after me: Public interfaces should be as small as possible.

### Can I deploy my service?

When multiple services share a single database, the question "Is it safe to
deploy this new code?" must be answered by multiple teams.

There are several scenario:

- __My new code won't change anything in the database:__ It is safe to deploy.

- __My new code has changed the DB schema:__ You must make changes in all services,
and deploy them at once.

- __My new code is deleting old records from the database:__ We need to ask
maintainers of all the services that share the DB. It is _maybe_ safe to deploy
your service.

Why would you do this to yourself? It is already hard enough to keep the public
API stable, why would you make deployment of new code even harder?

### End-to-end tests will save me!

No, they won't.

End-to-end tests of multiple services will answer the question
"Did you break something?", but they won't save you from the logistical
nightmare when you do indeed need to change and break something. There is no
other way, you need to rewrite code in multiple services.

### Better alternatives from sharing a database

The first best step is to precisely define what is the data that you want to
share between any two services. If you find that any two services need to share
almost all the data between them, then I would argue that you should merge those
two services into one.

When you finish the first step, you will have a good overview of your system and
the data that flows between them. Now, it is time to codify that information, and
provide a minimal set of well defined interfaces for your services. Two things
are important here. To precisely define the format of the messages, and to
provide the actions that your services are offering.

Separate the actions that can be executed asynchronously, and actions that
require immediate results. If possible, always prefer async actions, as they
will make your system more fault-tolerant.

Finally, you need to choose your preferred communication channels. For async
communication, message brokers like RabbitMQ are an excellent choice. For
in-sync communication REST/gRPC/Thrift are good candidates, choose your poison.

At first, this might seem like an impossibly huge task. However, good design
practices are always worth the investment. Good APIs are and always were the
backbones of every successful software endeavor.

Move slowly and understand what you are doing.
