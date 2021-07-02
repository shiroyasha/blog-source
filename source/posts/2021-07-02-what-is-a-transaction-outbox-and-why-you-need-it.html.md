---
id: ba61fc15-155b-4227-bfe4-68b0d11621b8
title: "Transactional Outbox: What is it and why you need it?"
date: 2021-07-02
tags: programming
image: 2021-07-02-what-is-a-transaction-outbox-and-why-you-need-it?.png
---

Receiving a request, saving it into a database, and then publishing a message
can be trickier than expected. A naive implementation can either lose messages,
or even worse publish incorrect messages.

Let's take an example where a user signs up, the backend saves this request to
the database, and finally publishes a "user-signed-up" message on RabbitMQ.
Based on this message, the User Greeter service sends a welcome message to the
user, while the Analytics service records a new signup and updates the business
dashboards.

![Transactional Outbox: Architecture Example](images/transactional-outbox/architecture-example.png)

Now, let's focus on the **User Registration Service** and try out several ways to
implement the registration action.

**Implementation 1: Publishing after the user insert transaction finishes**

Our first attempt to implement the register action will be to open a
transaction, save the user, close the transaction, and finally publish the
message to RabbitMQ.

``` ruby
def register_user(name)
  DB.transaction do
    user = User.new(name: name)
    user.save!
  end

  RabbitMQ.publish("user-signed-up", user.ID)
end
```

Now, lets examine what can go wrong with this implementation. We need to answer
three questions:

- What happens if RabbitMQ is temporarily available?
- What happens if writing to RabbitMQ fails?
- What happens if the service is restarted right after the transaction finishes,
  but right before the RabbitMQ message is published?

The answer to all three questions is: The user will be saved to the database,
but the message will not be published to the queue. The user will not get a
welcome message via email. Unacceptable!

**Implementation 2: Publishing before the user insert transaction finishes**

Publishing after a closed transaction leaves us in trouble. What if we try the
opposite and publish the message right before we close the transaction?

``` ruby
def register_user(name)
  DB.transaction do
    user = User.new(name: name)
    user.save!

    RabbitMQ.publish("user-signed-up", user.ID, user.Email)
  end
end
```

Now, lets examine this approach as well. It seems that this one is also
problematic:

If the transaction fails or rollbacks (for example, due to a uniqueness
constraint) we are going to publish a message to RabbitMQ that is not correct.

The user was **not created**, yet we still sent a "user-signed-up" message to
upstream services. Our service is lying. Unacceptable!

## Introducing the transactional outbox pattern

In the previous examples, if we published after the transaction we were in
trouble. However, we were in a similar trouble if we tried to publish before the
transaction was over.

It would be ideal if we could do those two actions at the same time, or at least
in the same transaction.
