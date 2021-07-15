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

Caching is a common tool that we utilize to make slow things faster.
Let's explore some caching strategies.

## Time-to-live based caching

One of the simple to implement caching strategies we can use to speed up a page
is to render the page and store it in the cache for an acceptable time period.

``` ruby
CACHE_EXPIRES_IN = 1.hour

def recent_orders(company_id)
  cached_page = Cache.find("recent_orders_page", company_id)

  if cached_page.present?
    return cached_page
  else
    content = full_render(company_id)

    Cache.store("recent_orders_page", company_id, content, ttl: CACHE_EXPIRES_IN)

    return content
  end
end

def full_render(company_id)
  orders = OrdersService.get_recent_orders(company_id)

  customer_ids = orders.map(&:customer_ids)
  customers = CustomerService.get_customer_details(customer_ids)

  render_page(orders, customers)
end
```
