---
title: Sms compiler service
tags: ruby
image: sms.png
---

The majority of today's development is oriented around the web or around desktop/mobile applications. For the average programmer it could even seem like there is no other programming area out there. However, there is actually a huge number of programs developed for cars, televisions, phones, and similar everyday technologies. This article is focused on a small fraction of those areas &mdash; sms messages.

## The code executor

Two or three months ago I watched [an episode on Computerphile](http://shiroyasha.github.io/sinatra-app-with-rspec.html), where a young programmer demonstrated his applications that receives code through sms messages, runs that code, and answers him back on his phone. I was fascinated with his applications, and today I will try to demonstrate the basics of this process, using a service that connects sms messages to web applications &mdash; [Twilio](https://www.twilio.com/). In a nutshell:

> Create a web application that receives ruby code from sms messages,
> executes that code, and sends back an sms with the output.

## Bootstrap

To achieve the above we will use the Sinatra web framework, and Twilio's
gem to receive SMS messages. Our Gemfile should look like this:

``` ruby
source "https://rubygems.org"

gem "rack"
gem "sinatra"
gem "activesupport"
gem "twilio-ruby"

group :test do
  gem "rspec"
  gem "rack-test"
end
```

Also, we will set up a Sinatra route that will receive Twilio's webhooks 
in our main application file.

``` ruby
post "/sms-code" do
  "Hello human!"
end
```

## Responding to sms messages

To respond to sms messages, we will have to use Twilio's `twiml` language,
and construct an XML response that Twilio can understand. To answer 
`Hello human!` to every incoming message we can do the following:

``` ruby
post "/sms-code" do
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message "Hello human!"
  end

  twiml.text
end
```

When we run our application and visit `/sms-code` we should see an output like this:

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Message>Hello Human!</Message>
</Response>
```

## Connecting this service to Twilio

At this point we should create a Twilio account with a phone number that will 
receive the messages and a place to host our application online. For example a 
[Heroku](https://www.heroku.com/) dyno would be an excellent choice.

After that we need to set up a webhook for our number on Twilio, where
all the incoming messages will arrive. We should visit our number's settings
and add the full URL to our sms handler. We will use the `POST` HTTP
method so that Twilio won't cache our requests and responses.
The setting screen should look similar to this:

![Webhook settings on Twilio](/images/twilio_number_setup.png)

**Note**: If you want Twilio to cache your responses, use the `GET` method.
In our use case we don't want that caching to happen so we use `POST`.

## Receiving the message

The previous example responded `Hello human!` to every received sms message.
We will now extend our application and use the body of the incoming sms 
message.

The following example takes the incoming message with `params[:Body]`
and evaluates it as executable Ruby code.

``` ruby
#
# This is very dangerous, 
# Don't do it without adult supervision!
#
def execute(code)
  eval(code)[0..160]
end

post "/sms-code" do
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message execute(params[:Body])
  end

  twiml.text
end
```

After deployment this code you should evaluate and return the results of
incoming sms messages.

**Note:** The above code segment uses the body parameter of the sms message
to evaluate some Ruby code. This is very dangerous, and is only used for 
demonstration purposes.

## Summary

Working with sms is really fun especially the part where your phone vibrates
and shows the result of your code. This exercise can also serve as a great
warm up before creating two factor authorization or similar sms bound systems.

Check out the [example repository on GitHub](https://github.com/shiroyasha/sms-ruby-code).

Happy hacking!
