---
title: Thor - Awesome CLI applications
tags: shell
image: thor-awesome-cli-apps.png
---

Have you ever wanted to create an awesome command line application but was lost in the sea of options parsing? Well, if you did, and even if you didn't, Thor is here to help you.

But what is Thor exactly? It is a powerful toolkit for writing command line applications in ruby that is used in various well known projects such as Rails, Vagrant, Bundler, and similar. It can even be used as a replacement for rake for creating task like methods and functions.

## Baby steps with Thor

When I stumble across something cool, my first instinct is to share and point out the most awesome parts of that thing. Usually, this is the worst approach for presenting things to other people. So now, I will try to hold back my geek instincts and start out simple. With a hello awesome world application. Here it is.

``` ruby
require "thor"

class  AwesomeHelloWorld < Thor

  desc "hello PLANET", "say hello to PLANET"
  def hello(planet)
    puts "Hello #{planet}"
  end

end

AwesomeHelloWorld.start(ARGV)
```

Save it to an appropriately named file `ahw.rb` and try to run it.

``` sh
$ ruby ahw.rb

Tasks:
ahw hello PLANET   # say hello to PLANET
ahw help [TASK]    # Describe available tasks or one specific task
```

``` sh
$ ruby ahw.rb hello uranus
hello uranus
```

As you can see in the above script has done so much instead of us. It created a help screen, it has a description for all of our tasks, and it can even parse and execute them appropriately.

## Digging deeper

Let's explore more of this awesomeness. Every task in a Thor application can accept command line flags with single or double dashes. To demonstrate this capability I will add a `--reverse` flag to our little hello task.

``` sh
desc "hello PLANET", "say hello to PLANET"
options :reverse => :boolean
def hello(planet)
  puts "Hello #{options{:reverse] ? planet.reverse : planet}"
end
```

Now if we call our task with the reverse flag it should display the name of the planet in reverse.

```
$ ruby ahw.sh hello MARS --reverse
hello SRAM
```

## Summary

Thor is one of the great tools to keep in your arsenal. I am frequently facing a task where I need to create a simple script but the one who will use it will be someone else. In those cases Thor comes in very handy.

Happy hacking!
