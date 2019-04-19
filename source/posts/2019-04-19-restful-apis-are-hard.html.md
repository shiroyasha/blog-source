---
id: d1c31507-14a8-4a58-9c14-918a2bf07d83
title: RESTful APIs are Hard
date: 2019-04-19
tags: programming
image: 2019-04-19-restful-apis-are-hard.png
---

I might be 20 years late to this party, but here it goes. I find RESTful APIs
hard to work with. They are deceptively complicated to get right.

In the begging they feel easy. You "just" create a resource, update it with a
`PATCH`, delete it with `DELETE`, and show the resource or list a collection
with `GET`. For such simple, stateless resources, this is truly easy. However,
life gets a bit more complicated once you try to model relationships between
your resources. Life gets much more complicated when you try to model processes
&mdash; objects that can be scheduled, canceled, stopped and retried.

Before I dig in deeper, I need to clarify what I mean when I say _hard_. I don't
mean they are hard to implement, usually they are pretty straightforward once
you have a working API interface. I don't mean they are hard to use either, on
the contrary, HTTP based REST APIs are one of the easiest interfaces to use. You
can basically start the exploration with `curl`. Good APIs are easy to explore.
The "hard" part is how to model them. For some reason, we still don't have a
collective understanding of how to do basic stuff. When designing REST APIs you
always feel like you breaking some standard, and sooner or later, you start
doing things that are not "proper" but pragmatic.

In the rest of this post I'll use `GET /resource/1` and `POST /resource` form to
give examples. This is not really the core point of the REST approach, but in
practice, it modeling issues boil down to choosing the proper URLs for resource
representation.

## Modeling singular resources tied to the actor

Let's start with a basic example. We have a list of `article` resources and we
want to allow our users to `like` them. Sounds simple.

**The pragmatic approach**:

First we create an article with `POST /articles`, then we `GET /articles/1`,
and finally we `POST /articles/1/like`. To unlike an article
`DELETE /articles/1/like`. To list the likes `GET /article/1/likes`.

This approach has several assumptions. There is a known actor on the client side,
the actor can only leave one like, and the actor can only leave a like for
themselves, not for others.

But is this design correct, and follows "good practices" of REST?
How to check if someone else liked an article? `GET /article/1/likes` and find
his name in the returned list?

**The every resource needs to have an ID approach**:

In this scenario every like needs to have an ID. So we create an article with
`POST /articles`, then `GET /articles/1`, and finally we
`POST /articles/1/likes`. To delete this like we `DELETE /articles/1/likes/1`.

This "feels" more RESTful. Also our system can grow and potentially support
more than one one like per user per article. But for now, we need to keep in
mind to add one extra validation into our system to prevent multiple likes from
a user. The pragmatic approach was simpler for the consumer in this regard, the
like was either present or not present, there was no chance for multiple likes.

**The flat namespace approach**:

In this scenario we only allow one level of nesting for URLs while creating a
resource. `POST /articles` to create an article.
`POST /likes?article_id=1` to create a like resource. To list likes we `GET
/articles/1/likes`.

Flat namespaces are generally nice, but what is really the benefit of this
approach?

**The screw REST, we will do RPC over HTTP**

At some point companies decide that simple REST is not easy enough. So they
start abandoning everything that REST stands for, and start doing `POST
/articles` to create an article, `POST /articles/1/leave.like` to leave a like,
and `POST /articles/1/unlike` to unlike.

Feels ugly. This is the most pragmatic you can get and still claim that you
have a RESTful API.

## Modeling processes

Process modeling is a subject that I am intimately familiar with as an engineer
that works on a CI system. Most of our resources are processes.

Let's take for example a Job, a unit of work that needs to be executed on a
physical machine. What can we do with such a resource? We can schedule it, we
can stop it, we can rerun it, and we can describe it, to name a few.

Scheduling and describing are the simple actions. To schedule a job `POST
/jobs`. To describe the status of the job `GET /jobs/1`.

Stop and rerun are a different beast.

**The pragmatic stop and rerun actions**:

The simplest solution we can think for stop is the `POST /jobs/1/stop`. It's
fast, it's a bit dirty, but it gets the job done.

Now, one thing we need to keep in mind is that stopping a job can't be an
instantaneous action, we need to shut down a virtual machine. So in practice,
our call to `POST /jobs/1/stop` has actually only requested a stop as soon
as possible. Do we want to allow canceling a stop action?

To rerun a job, you would do `POST /jobs/1/rerun`. Ah, this really feels dirty.
Did we just created a `rerun` resource in the system?

**The updates via PATCH approach**

We can say that stopping a job is actually updating its state. If we are
updating the state, we need to use `PATCH`, right?

Execute `PATCH /jobs/1 state=stopped` to stop a job.

But again, a stop action is not immediate, the system still need to execute
something in the background. So to be a bit more correct, we should do the
following instead:

Execute `PATCH /jobs/1 stopping_requested=true` to stop a job.

It follows "good practices" of RESTfull design, so it must be correct.

A user might even try to execute `PATCH /jobs/1 stopping_requested=false` to
unstop a stopped job.

**Actions that have a temporal dimension need to be resources stopping approach**:

Because stopping a job is not an instantaneous approach, we might want to model
it as as another resource in the system:

`POST /jobs/1/stop_requests` schedules a stop action for a given job.

This feels clean. However, we now have an extra resource in the system. An extra
resource that needs to be explained to the user of the system.

Is this truly a better approach compared to the pragmatic `POST /jobs/1/stop`
action? If yes, why is better? If no, why not?

Can we have two concurrent stopping requests on the same job?

**Rerun a job by scheduling a new job with the same data approach**:

If `POST /jobs/1/rerun` doesn't feel correct
