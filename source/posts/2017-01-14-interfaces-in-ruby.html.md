---
id: 35df3513-e739-4d6d-82f4-85580c58fac4
title: The Power of Interfaces in Ruby
date: 2017-01-14
tags: hidden
image: interfaces-in-ruby.png
---

Ruby is not the fastest language, nor is it the simplest language, but damn it,
it is definitely one of the most fun languages out there. For someone like me,
who enjoys programming maybe a bit too much, a language that puts little or no
limitations on the things I can tweak feels very natural and an obvious choice
when it comes to solving complex issues.

READMORE

While I really do love the Ruby language, sometimes I find myself missing
features that are available elsewhere. For example, lightweight threads like in
Go, or easy access to memory like in C.

Lately, I started missing _interfaces_ from Java.

## Interfaces

I was never a big fan of Java, the syntax is a bit too verbose for my taste.
However, I always found the concept of interfaces interesting. I think that they
are an excellent tool to communicate intent and to set up constraints on the
objects that implement them.

For example, in Java, if I want to say that an object can be transformed to and
from CSV (comma separated values) I could simply declare a CSV interface.

``` java
interface CSV {
  public void fromCSV(String line);
  public String toCSV();
}
```

Now, I can be sure that every object that implements that interface can be
transformed to and from a CSV file. Here are two examples:

``` java
class User implements CSV {
  public String toCSV() {
    return this.name + "," + this.age + "," + this.password;
  }

  public void fromCSV(String csvLine) {
    String[] parts = csvLine.split(",");

    this.name = parts[0];
    this.age = parts[1];
    this.password = parts[2];
  }
}

class Book implements CSV {
  public String toCSV() {
    return this.title + "," + this.author;
  }

  public void fromCSV(String csvLine) {
    String[] parts = csvLine.split(",");

    this.title = parts[0];
    this.author = parts[1];
  }
}
```

Some people argue that interfaces are not important in Ruby, and that I should
simply embrace the language and rely on duck typing.

This is however in direct opposition of what Ruby is all about. The Ruby
community is well known for not accepting the status quo, and not limiting
itself by what is currently available in the core of the language.

## Interfaces in Ruby with modules

The simplest way to emulate interfaces in Ruby is to declare a module with
methods that raise a "not implemented" exception.

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
If we include the `CSV` module and forget to implement the `to_csv` method, we
won't notice this mistake until we run our code and an exception pops up.

This completely defeats the purpose of interfaces. I want to catch
inconsistencies __before__ I execute my code. If the `CSV` module can't
guarantee that, than what is its purpose? Does it act like a simple todo list
for the methods I need to implement, without any actual checks?

## Describing behaviour

Instead of focusing on the syntax, it is probably better to focus on the
semantics of interfaces. What I actually want, is a set of constraints that
define the behaviour of an object, and check them before I run my application.

When we put it that way, it is very obvious that what I want is actually a set
of tests that describe my object. For the previous CSV example, we could write
the following in RSpec:

``` ruby
shared_examples "a CSV serializable object" do
  it { is_expected.to respond_to(:to_csv) }
  it { is_expected.to respond_to(:from_csv) }
end
```

This is exactly the constraint that I expect from my object.

We can use the above definition as a substitute for interfaces in Ruby. If we
want to enforce that an object can be transformed to and from CSV, we can simply
drop a line in their specs:

``` ruby
describe User do
  it_behaves_like "a CSV serializable object"
end

describe Book do
  it_behaves_like "a CSV serializable object"
end
```

## Tests are better than interfaces

Many things that are traditionally enforced with type systems are checked via
unit tests in dynamically typed languages.

Type systems can be helpful, but it is very hard to define a type system that is
simple enough, and at the same time strong enough to actually help the developer
to write correct code. From my experience, type systems are an excellent
tool to let the compiler know where to optimize your code, but I still am not
convinced that it actually helps the developers to write better code.

The same is true for interfaces. They are able to describe the behaviour of an
object, but they are fundamentally limited. Unit tests can describe much, much
more about an object.

For example, to describe the behaviour of objects that act as collections, we
can write down the following:

``` ruby
shared_examples "a collection" do
  it { is_expected.to respond_to(:add).with(1).argument }
  it { is_expected.to respond_to(:remove).with(1).argument }
  it { is_expected.to respond_to(:include?).with(1).argument }
end
```

This is roughly equivalent to an interface in Java, but why stop here? We can
write down a lot more things that we expect from a collection.

``` ruby
shared_examples "a collection" do
  it { is_expected.to respond_to(:add).with(1).argument }
  it { is_expected.to respond_to(:remove).with(1).argument }
  it { is_expected.to respond_to(:include?).with(1).argument }

  before do
    @collection = described_class.new
  end

  describe ".add" do
    it "adds an element into the collection" do
      @collection.add(12)

      expect(@collection).to include(12)
    end

    it "returns the collection" do
      expect(@collection.add(12)).to eq(@collection)
    end
  end

  describe ".remove" do
    context "the element is not present" do
      it "doesn't raise an exception" do
        expect { @collection.remove(12) }.to_not raise_exception
      end
    end

    it "removes all the elements from the collection" do
      @collection.add(12)
      @collection.add(12)

      expect(@collection).to include(12)

      @collection.remove(12)
      expect(@collection).to_not include(12)
    end

    it "returns the collection" do
      expect(@collection.remove(12)).to eq(@collection)
    end
  end
end
```

Just look at the above example, and realize how much stronger are the above tests
compared to a simple interface. We have successfully enforced and communicated
to fellow developers the following:

- A collection must answer to `add`, `remove` and `include?` methods
- The arity of the methods and their return values
- The `remove` method removes all the values from the collection
- No exception is raised when `remove` is called on an empty collection

## Avoiding mistakes and trusting unit tests

Until now, I frequently used the "not implemented" exception to communicate
intent to other developers in my team. I used it to define interfaces, and also
to define virtual methods on base abstract classes.

``` ruby
# to define an interface

module JsonSerialization
  def to_json
    raise "Not Implemented"
  end
end

# to define virtual methods

class Vehicle
  def speed
    raise "Not Implemented"
  end
end
```

I now realize that this was a mistake. Instead of doing this, I should have
relied on the implicit `NoMethodError` that is raised by default in Ruby, and
to use tests to describe the behaviour of my objects.

That's all.<br>
Keep learning, Ruby is great.
