---
title: Sms compiler service
date: 2014-12-08
tags: ruby
image: sms.png
---

The majority of todays development is oriented around the web or around desktop/mobile applications. For the average programmer it could even seem like there is no other programming area out there. However, there is actually a huge number of programs developed for cars, tvs, phones, and similar everyday tehnologies. This article is focused on a small fraction of those areas &mdash; sms messages.

## The code executor

Two or three months ago I watched [an episode on Computerphile](http://shiroyasha.github.io/sinatra-app-with-rspec.html), where a young programmer demonstrated his applications that recieves code through sms messages, runs that code, and aswers him back on his phone. I was fascinated with his applications, and today I will try to demonstrate the basics of this process, using a service that connects sms messages to web applications &mdash; [Twillio](https://www.twilio.com/). In a nutshell:

> I will create a web application that recevices ruby code from sms messages, executes that code, and sends back an sms with the output.

## Bootstrap

To achive the above I will use Sinatra web framework and twillios gem to receive sms messages. My Gemfile looks like this:

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

Also, I will have a route set up to receive Twillios webhooks in my main application file.

``` sh
post "/sms-code" do
  "Hello human!"
end
```

## Responging to sms messages

To respond to sms messages, you will have to use Twillios `twiml` language, and construct an xml response that Twillio can understand. To answer `Hello human!` to every incoming message you can do the following

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

## Connection this service to Twillio

At this point you should create a Twillio account with a phone number that will receive the messages, and a server from which your application will be available on the internet, for example a [Heroku](https://www.heroku.com/) server is a good choice.

After that go to your numbers settings on Twillio and set the webhook url to the location of your web application. Choose `POST` as a method of communication.

**Note**: If you want twillio to cache your responses, use the `GET` method. In our use case we don't want that caching to happen so we use `POST`.

## Receiving the message

The previous example responded `Hello human!` to every recieved sms. Now we will extend our application and use the body of the sms message to respond according to it.

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

After you deploy this code you should be able to send some ruby code to your phone and recieve its output. Enjoy!

**Note:** The above code segment uses the body parameter of the sms message to eveluate some ruby code. This is very dangerous, and is only here for demonstration purpuse.

## Summary

Working with sms is really fun expecially the part where my phone vibrates and shows me the result. This can be also a great excercise for creating two factor authorization or similar usefull things.

Also check out the [example repository on Github](https://github.com/shiroyasha/sms-ruby-code).

Happy hacking!
