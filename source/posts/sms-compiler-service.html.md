---
title: Sms compiler service
date: 2014-12-08
tags: ruby
image: sms.png
---

The majority of today's development is oriented around the web or around desktop/mobile applications. For the average programmer it could even seem like there is no other programming area out there. However, there is actually a huge number of programs developed for cars, televisions, phones, and similar everyday technologies. This article is focused on a small fraction of those areas &mdash; sms messages.

## The code executor

Two or three months ago I watched [an episode on Computerphile](http://shiroyasha.github.io/sinatra-app-with-rspec.html), where a young programmer demonstrated his applications that receives code through sms messages, runs that code, and answers him back on his phone. I was fascinated with his applications, and today I will try to demonstrate the basics of this process, using a service that connects sms messages to web applications &mdash; [Twilio](https://www.twilio.com/). In a nutshell:

> I will create a web application that receives ruby code from sms messages, executes that code, and sends back an sms with the output.

## Bootstrap

To achieve the above I will use Sinatra web framework and Twilio's gem to receive sms messages. My Gemfile looks like this:

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

Also, I will have a route set up to receive Twilio's webhooks in my main application file.

``` sh
post "/sms-code" do
  "Hello human!"
end
```

## Responding to sms messages

To respond to sms messages, you will have to use Twilio's `twiml` language, and construct an xml response that Twilio can understand. To answer `Hello human!` to every incoming message you can do the following

``` ruby
post "/sms-code" do
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message "Hello human!"
  end

  twiml.text
end
```

When you run the application and visit `/sms-code` you should see an output like this

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Message>Hello Human!</Message>
</Response>
```

## Connecting this service to Twilio

At this point you should create a Twilio account with a phone number that will receive the messages, and a server from which your application will be available on the internet, for example a [Heroku](https://www.heroku.com/) server is a good choice.

After that go to your numbers settings on Twilio and set the webhook url to the location of your web application. Choose `POST` as a method of communication.

**Note**: If you want Twilio to cache your responses, use the `GET` method. In our use case we don't want that caching to happen so we use `POST`.

## Receiving the message

The previous example responded `Hello human!` to every received sms. Now we will extend our application and use the body of the sms message to respond according to it.

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

After you deploy this code you should be able to send some ruby code to your phone and receive its output. Enjoy!

**Note:** The above code segment uses the body parameter of the sms message to evaluate some ruby code. This is very dangerous, and is only here for demonstration purpose.

## Summary

Working with sms is really fun especially the part where my phone vibrates and shows me the result. This can be also a great exercise for creating two factor authorization or similar useful things.

Also check out the [example repository on GitHub](https://github.com/shiroyasha/sms-ruby-code).

Happy hacking!
