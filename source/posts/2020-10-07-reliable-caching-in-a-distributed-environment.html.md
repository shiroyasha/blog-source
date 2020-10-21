---
id: a484ffff-201c-4bd0-944f-9f8d503e88b2
title: Reliable caching in a distributed environment
date: 2020-10-07
tags: programming
image: 2020-10-07-reliable-caching-in-a-distributed-environment.png
---

Fast response times are one of the key expectations we, as customers, have from
any web application. For web applications that process a big amount of data,
data that is perhaps generated automatically, have a challenge to meet this
expectation.

Composing a web application from multiple services, known as the microservice
architecture, doesn't help with performance. A web page in such architectures
can depend on multiple upstream services with various levels of response times.
The microservice architecture can be a great solution for various operational
concerns, but out-of-the-box performance is rarely a highlight of this
architecture. In this regard, monolithic applications have an edge.

To explore this problem, lets look at the following example screen that depends
on three upstream APIs to construct the page.

![](/images/distributed-caching-example-001.png)

To render the page, we need to collect information from three backend services.
The accounts service, the endpoints service, and the service that collects
metrics data.

For this page to be considered "fast" a good rule of thumb on the web is to be
able to provide a response under 250ms. This requirement cascades up the
service dependency tree and puts a hard limit on the response times for the
upstream services.

## Setting up a caching mechanism

The general solution in computing for speeding up response times is caching.
For example, if you send a request to my web application, I can calculate and
store the state of your request. The second time you send the same request, I
can avoid calculating and return a pre-calculated value from memory.

---

Learn how to set up a reliable caching system in a distrubed, 
event based, environment.

# Event Based Caching Systems

Fast response times are one of the main responsibilities of web
developers. Applications that have 500ms or slower responses are
frustrating end users, and detracting the public image of your 
product.

Caching is one of main methods how we improve the response times
in our applications. However, setting up a reliable caching system
in a system that is composed of multiple service can be challenging.

In this article we are going to explore an event based solution to
this problem. A caching system will react to the events in our system
and pre-populate the responses for web applications.

# Problem

A caching system is concerned about three topics:

- What to store in the cache?
- When to invalidate the cached data?
- The fallback to use if cached data is not available?

In monolithic, single database systems, transactions can help
in all three situations. For examples, one could use the
following strategy:

``` ruby
user = User.find(id)

profile_page = Cache.lookup("user-profile-#{user.updated_at}")

if profile_page == nil
  profile_page = render_profile_page(user)  

  Cache.store("profile-page-#{data.user_id}", profile_page)
end

return profile_page
```

Now, every time the user record is updated, the `update_at` field
will be updated, and the associated cache key will no longer point
to an existing record.

** diagram **

This implementation has one hidden assumption: It is cheap and fast
to access the database to read out the user record.

In a distrubuted system, the assumption that the access to the user
record is fast and cheap could be a dangerous one. Such design 
decisions can put unwanted presure to the maintainers of the system,
and unnecessaraly tangle up the reliance of one system on the other.

We want to design a system that can decouple the heavy reliance of 
the client on the server.

# Solution

Our goal is to desing a system that reduces the burden of the client
on the server, and allows the client to invalidate its cache without
contacting the backend system.

We will be relying on a messaging system to inform the clients that
the cache needs to be updated.

** diagram **

In this system, every time the user record is updated, a 
"user_updated" message is published. The client is reacting to this
message and invalidating the cache record.

``` ruby
user.update(...)

MessageBroker.publish(
 event: "user_updated",
 data: {user_id: id, user_name: name}
)
```

On the client side, we will consume the messages and invalidate the
cached profile page records:

``` ruby
MessageBroker.consume("user_updated", fn data ->
  Cache.invalidate("profile-page-#{data.user_id}")
end)
```

In the web request:

``` ruby
def profile_page(req) 
  profile_page = Cache.lookup("profile-page-#{request.user_id}")

  if profile_page == nil
    profile_page = render_profile_page(req)  

    Cache.store("profile-page-#{data.user_id}", profile_page)
  end

  return profile_page
end
```

## Pre-populating the cache

A natural extension of the system is to push the docupling of the
system even further and pre-populate the cache.

When the client receives the message from the server, we can 
imidiately render the new profile page.

``` ruby
MessageBroker.consume("user_updated", fn data ->
  profile_page = render_profile_page(data)

  Cache.store("profile-page-#{data.user_id}", profile_page)
end)
```

Now, the web request is totally independent of the backend service.

** diagram **

## Latency problems with the pre-populating strategy

## Cardinality problems with the pre-populating strategy

## Strategies for monitoring the caching system
