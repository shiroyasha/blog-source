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

<hr style="width: 50%; margin-top: 3em; border-color: gray;">

**Problem Statement**: If we publish in the transaction, we can publish a fake
message. If we publish after the transaction, we are risking that we will never
publish the message. How to guarantee message dispatching?

## The transactional outbox pattern

Using a transactional outbox is one way to solve this problem.

We will introduce an auxiliary database table, called outbox, that will store
outgoing messages from our service. A publisher service will than read from this
table and publish messages to the queue.

![Transactional Outbox](images/transactional-outbox/outbox.png)

In code, the registration controller would do the following:

``` ruby
def register_user(name)
  DB.transaction do
    user = User.new(name: name)
    user.save!

    outbox = Outbox.new(
      "message": json({user_id: user.ID}),
      "exchange": "users",
      "routing-key": "user-signed-up")

    outbox.save!
  end
end
```

In the meantime, a Publisher service polls the outbox table and publishes the
messages to RabbitMQ.

``` ruby
module Publisher
  def start
    loop do
      poll_and_publish()
      sleep(1.second)
    end
  end

  def poll_and_publish
    transaction do
      # SELECT * FROM outbox FOR UPDATE SKIP LOCKED LIMIT 10
      messages = Outbox.lock("FOR UPDATE SKIP LOCKED").limit(10).load()

      messages.each do |msg|
        RabbitMQ.publish(msg)

        Outbox.delete(msg.id)
      end
    end
  end
end
```

## Problems resolved by the transactional outbox?

## Problems not resolved by the transactional outbox?
























