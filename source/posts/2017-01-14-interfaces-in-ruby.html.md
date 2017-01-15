---
id: 35df3513-e739-4d6d-82f4-85580c58fac4
title: Interfaces in Ruby
date: 2017-01-14
tags: programming
image: 2017-01-14-interfaces-in-ruby.png
---

Ruby is not the fastest language, nor is it the simplest language, but damn it,
it is definitely one of the most fun languages. For someone like me, who enjoys
programming maybe a bit too much, a language that puts little or no limitations
on the things I can tweak feels very natural and an obvious first choice when it
comes to solving complex issues.

## Interfaces

I was never a big fan of Java, the syntax is a bit too verbose for my taste.
However, I always found the concept of interfaces interesting. I think that they
are an excellent tool to communicate intent and to set up constraints on the
objects that implement them.

For example, in Java if I wanted to say that an object can be transformed to and
from CSV (comma separated values) I could simply declare a CSV interface.

``` java
interface CSV {
  void fromCSV(String line);
  String toCSV();
}
```

Now, I can be sure that every object that implements that interface can be
transformed to and from a CSV file. Here are two examples:

``` java
class User implements CSV {
  String toCSV() {
    return this.name + "," + this.age + "," + this.password;
  }

  void fromCSV(String csvLine) {
    String[] parts = csvLine.split(",");

    this.name = parts[0];
    this.age = parts[1];
    this.password = parts[2];
  }
}
```

``` java
class Book implements CSV {
  String toCSV() {
    return this.title + "," + this.author;
  }

  void fromCSV(String csvLine) {
    String[] parts = csvLine.split(",");

    this.title = parts[0];
    this.author = parts[1];
  }
}
```

## Interfaces in Ruby with modules

Some people argue that interfaces are not important in Ruby, and that I should
simply embrace the language and rely on duck typing. This is however is in
direct opposition of what Ruby is all about. The Ruby community is well known
for not accepting the status quo, and always embracing new ideas.

The simplest way to emulate interfaces in Ruby is to declare a module with
methods that raise a not implemented exception.

``` ruby
module CSV

  def to_csv
    raise "Not implemented"
  end

  def from_csv(line)
    raise "Not implemented"
  end

end
```

Now, we can use that module to communicate what needs to be implemented on the
objects in order to support CSV transformations.

``` ruby
class User
  include CSV

  def to_csv
    "#{@name},#{@age}"
  end

  def from_csv(line)
    parts = line.split(",")

    @name = parts[0]
    @age = parts[1]
  end

end
```

This looks and feels like interfaces in Java, however there is a huge downside.
If we include the `CSV` module and forget to implement `to_csv`, we won't notice
this issue until we run our code and an exception pops up.

This completely defeats the purpose of interfaces. I want to catch
inconsistencies __before__ I execute my code. If the `CSV` module can't
guarantee that, than what is its purpose? Does it act like a simple todo list
for the methods I need to implement, without any actual checks?

## Interfaces in Ruby with modules
