---
id: 0148d118-2d34-4eb0-bcb0-5f546953d12a
title: Proactive cache warming in a microservice-based architecture
date: 2021-07-14
tags: programming
image: 2021-07-14-proactive-cache-warming-in-a-microservice-based-architecture.png
---

With the microservice architecture style, services and their data are contained
within a single bounded context. This architectural decision helps us developing
and deploying changes in the business unit fast and independent of other
services our system. However, collecting and analyzing data from multiple
services can be much harder and slower than in a typical monolithic service
where the caller has access to data from a single big database system.

Let's look at an example. A web application that allows its users to place
orders wants to add a new page that displays information about the most recent
orders in a company.

![Proactive Cache Warming: Architecture Example](images/proactive-caching/architecture-example.png)

We will focus on the front service, more specifically on its recent orders
controller action. The most straightforward implementation would reach out to
the orders service and the customers services sequentially, merge the data, and
render the HTML page.

``` ruby
def recent_orders(company_id)
  orders = OrdersService.get_recent_orders(company_id)

  customer_ids = orders.map(&:customer_ids)
  customers = CustomerService.get_customer_details(customer_ids)

  render_page(orders, customers)
end
```

Our next challenge is how to make this page fast.

Lets assume for the sake of the argument that both the Orders Service and the
Customers Services take around `200ms` to respond, and that we don't have any
viable way of making these response times faster.

This sets the minimal time to render the page to `400ms` plus the time it takes
to process the data and prepare the HTML page. Let's say that the later part
takes `100ms`. In total, `500ms` to respond.

Caching is a common tool that we utilize to make slow things faster. Key/Value
memory stores like redis can easily support `1ms` response times.

Let's explore some caching strategies.

## Time-to-live based caching

A simple-to-implement caching strategy is a time based one. This strategy
renders the page and keeps in the cache for a given amount of time.

``` ruby
CACHE_EXPIRES_IN = 1.hour

def recent_orders(company_id)
  key = cache_key(company_id)
  cached_page = Cache.find(key)

  if cached_page.present?
    cached_page
  else
    content = full_render(company_id)

    Cache.store(key, content, ttl: CACHE_EXPIRES_IN)

    content
  end
end

def cache_key(company_id)
  "recent_orders_page_#{company_id}"
end

def full_render(company_id)
  orders = OrdersService.get_recent_orders(company_id)

  customer_ids = orders.map(&:customer_ids)
  customers = CustomerService.get_customer_details(customer_ids)

  render_page(orders, customers)
end
```

This strategy can be an ideal one when the domain of the problem is time bound.
For example, if the page would display orders processed for the last day,
instead of listing all the most recent ones.

The most significant downside is that the page will not refresh its content
even if a new order is placed into the system. It will be fast, but stale.

## Signature based caching

Another way to improve the speed of our page is to fetch some minimal amount of
data that can signal to our system if our cached value is stale or still viable.

Let's assume that in the above example, the order processing system has an
endpoint that can return us the timestamp of the last processed order by a given
company. Let's also assume that the service can provide us with this data under
`100ms`.

We can use this information to optimize our rendering function.

``` ruby
def recent_orders(company_id)
  last_order_at = OrdersService.get_last_order_timestamp(company_id)
  key = cache_key(company_id, last_order_at)

  cached_page = Cache.find(key)

  if cached_page.present?
    cached_page
  else
    content = full_render(company_id)

    Cache.store(key, content, ttl: CACHE_EXPIRES_IN)

    content
  end
end

def cache_key(company_id, last_order_at)
  "recent_orders_page_#{company_id}_#{md5(last_order_at)}"
end

def full_render(company_id)
  orders = OrdersService.get_recent_orders(company_id)

  customer_ids = orders.map(&:customer_ids)
  customers = CustomerService.get_customer_details(customer_ids)

  render_page(orders, customers)
end
```

This implementation makes sure that we never have a stale state on the page,
however, the performance gains are not so good as in our previous iteration.

In case we have a cache hit, the performance will be around `100ms` as it takes
this long to fetch the timestamp of the last order.

In case we have a cache miss, the performance will be worse than it would be
without caching. We will need `100ms` to find the timestamp of the last order,
plus the `500ms` duration for the full page render.

## Event based caching

In both of the previous implementations the core problem was how and when to
clear the cached values. It turns out it is quite hard to deduce this on the
client side.

One strategy common in distributed systems is to use events to propagate
information about state changes. We can use this architecture to have a clear
signal when our cache needs to be cleared.

![Proactive Cache Warming: Event Based Cache Invalidation](images/proactive-caching/invalidation.png)

In this architecture, both the order processing service and the customer service
are publishing events when their datasets change. The cache invalidator then
listens to those events and clears the data from the UI layer's cache.

``` ruby
def recent_orders(company_id)
  key = cache_key(company_id)
  cached_page = Cache.find(key)

  if cached_page.present?
    cached_page
  else
    content = full_render(company_id)

    Cache.store(key, content)

    content
  end
end

subscribe("orders_service", "order-created") do |event|
  key = cache_key(event.company_id)

  Cache.clear(key)
end

subscribe("customers_service", "customer-updated") do |event|
  key = cache_key(event.company_id)

  Cache.clear(key)
end
```

With this architecture we can achieve pretty fast response times and up-to-date
content in the cache.

In case we have a cache hit, we can respond under `1ms`, the amount of time it
takes to fetch the data from the cache.

In case we have a cache miss, we can respond in `500ms`, the amount of data it
takes to have a full page render.

This solution is better in both cases from the signature based caching solution
we explored in the previous section.
