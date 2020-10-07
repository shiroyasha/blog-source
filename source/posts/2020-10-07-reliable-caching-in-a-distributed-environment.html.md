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
on five upstream APIs to construct the page.

![](/images/distributed-caching-example-001.png)

The first optimization measure we can introduce is to fetch the upstream data
from the APIs in parallel. Assumed that the loaded data has no relationships
that would force us two serialize these requests, we can fetch with:

``` elixir
user_data_fetch_task = Task.run(fn -> UserService.fetch_data() end)
endpoints_fetch_task = Task.run(fn -> EndpointService.fetch_data() end)
metrics_fetch_task   = Task.run(fn -> MetricsService.fetch_data() end)

{:ok, user_data} = Task.await(user_data_fetch_task)
{:ok, endpoints} = Task.await(endpoints_fetch_task)
{:ok, metrics}   = Task.await(metrics_fetch_task)

render_page(user_data, endpoints, metrics)
```

Usually, web applications set a goal to respond in 250ms or less to the caller.
If we take some assumptions, like that rendering of the fetched data takes
around 50ms, we can set an upper limit for our upstream APIs. Every upstream
service must respond in 200ms or less

Now, to ensure optimal performance of 250ms or less, we must guarantee that the
three upstream services have faster than 200ms response times. However, any
reasonable team would not accept an upper limit for response times without a
well defined defect budget. Let's define that limit to be 0.1%.

Math can give us a hard time. If each service has a 99% percentage of fast
responses, we can find out that the defect rate of our service is lower than we
might expect. Let's look at the formula:

1 - (1 - 0.1)^3 = 0.02

Or in other words, 2% of the requests for the whole page will not hit the 250ms
target. The situation gets even worse if we increase the number of upstream
services.


The general solution in computing for speeding up response times is caching.
For example, if you send a request to my web application, I can calculate and
store the state of your request. The second time you send the same request, I
can avoid calculating and return a pre-calculated value from memory.
