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
