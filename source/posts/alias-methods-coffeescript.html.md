---
title: Alias methods &mdash; CoffeeScript
date: 2014-10-10
tags: coffeescript
image: alias-methods-coffeescript.png
---

In programming we like to reuse stuff. Data, variables, classes and even whole systems. We have a rule of thumb to only write code if it can not be found somewhere else. But sometimes the same thing can have a different meaning in a different context. So in order to reuse code but have a meaningful name in various contexts, we use aliases.

In CoffeeScript we don't have an explicit alias method like in Ruby or Bash Script, but we have something better &mdash; **functions as data**.

Let's start with the basics. To create an alias for a function we can just assign one value to the other

``` coffeescript
subtract = (a, b) -> a - b

minus = subtract

subtract(10, 6)    # => 4
minus(10, 6)       # => 4
```

If we have a method in a class, unfortunately we can't just assign one value to the another because we would lose the context of the `this` value. Luckily, CoffeeScript has a nice little operator &mdash; `@::` &mdash; that can assign one method to another name.

``` coffeescript
class Stack

  constructor: () ->
    @_list = []

  push: (value) ->
    @_list.push(value)

  append: @::push
  add   : @::push


s = new Stack()

s.push(5)
s.append(10)
s.add(3)

s._list  # => [5, 10, 3]
```

## Parameterized aliases

Sometimes a simple alias is not enough. The new name represents a subset of a more general function that takes more arguments than the new one we want to create. In a pure object oriented paradigm this is usually known as a factory.

Come back! Factory aren't so scary in CoffeeScript as they are in for example Java. All we have to do is to redefine our original method to Carry style. Here is a nice example for logging data

``` coffeescript
show = (logType) -> (message) ->
  console.log("#{logType}: #{message}")

info    = show("INFO")
error   = show("ERROR")
warning = show("WARN")

info("a simple test")    # => "INFO: a simple test"
error("a simple test")   # => "ERROR: a simple test"
warning("a simple test") # => "WARN: a simple test"
```

Notice how I have defined the `show` function. It is a function that returns another function. Weird... but powerful and elegant.

To achieve the same in a class, we can do something very similar. Here is an example class that uses parameterized aliases to send out ajax requests.

``` coffeescript
class HTTP

  _request = (method) -> (data = {}, callback = nil) ->
    $.ajax({
      method: method
      url: @url
      data: data
    }).done(callback)

  constructor: (@url) ->

  get:    _request "get"
  put:    _request "put"
  post:   _request "post"
  delete: _request "delete"

api = new HTTP("/v1/testApi")

api.post { hello: "world" }, (response) ->
  console.log response

api.get (response) ->
  console.log response
```

That's it. Happy hacking!
