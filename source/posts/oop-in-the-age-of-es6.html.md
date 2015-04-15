---
title: OOP in the age of ES6
date: 2015-04-15
tags: javascript
image: es6-ninja.png
---

Recently, I have become more of a "Ruby/Bash/Haskell" guy, but 
JavaScript will always remain one of my favorite languages, and I
couldn't be happier when I saw the new new upcoming ES6 standard.

ES6 is the new sexy ECMAScript standard that brings a lot of goodies
to the JavaScript world. One of the new features I am really looking
forward to is the new classical OOP system.

If you are familiar with JavaScript, you probably know that that it 
uses an alternative version of Object Orientation that relies on 
object prototypes. While in theory the prototypical nature of JavaScript
is superior to the classical version, in the sense that it can simulate
the later, in practice it is often confusing and a common source of bugs.

The new OOP system on the other hand is intuitive and comparable to 
the system implemented in Ruby, Python or Scala. This article will
demonstrate some of the awesome things that you can soon use in your
daily JavaScript development.

## Constructing classes

Finally the useless reserved word `class` can shine. The 
new OOP system uses it to define new classes. Here is an example:

``` javascript
class Dog {
  constructor(name) {
    this.name;
  }

  bark() {
    console.log("wuf! wuf!");
  }
}

var leo = new Dog("Leo");
leo.bark();
```

At the first glance, we can instantly recognize the intuitiveness of
the above construct. It defines a `Dog` class with a _constructor_ 
that takes it name, and an instance method that let's our dogs to bark.

Notice also that the methods don't have a `function` keyword and that
there is no `prototype` word anywhere in the source file. Just as a 
reminder of the old days, I will rewrite the above class to the current
ES5 format:

``` javascript
function Dog(name) {
  this.name;
}

Dog.prototype.bark = function() {
  console.log("wuf! wuf!");
};

var leo = new Dog("Leo");
leo.bark();
```

You can argue that this version is shorter, but it is definitely 
weirder no matter how you look at it.

## Inheritance

If you were amazed with the new system, prepare yourself for even
more. Inheritance was always one of the most confusing parts of
prototypical OOP. 

  - How do I define my parent class?
  - How do I redefine methods in the inherited class?
  - How to pass arguments to the parent's constructor?

The above questions always boggled my mind. I learned them when I
needed them, but after a week or two I completely forgot them.
Luckily for me, the new system uses `extends` and `super`.

Let's extend the above `Dog` class to a subtype of dogs, for example
Labradors:

``` javascript
class Labrador extends Dog {
  constructor(name) {
    super(name); 
  }

  playWithKids() {
    console.log("playing with kids! wuf! wuf!")
  }
}

var leo = new Labrador("Leo");
leo.playWithKids();
```

But how do you redefine a method? Let's say for the sake of the
following example that Labradors have a different kind of bark
that instead of `wuf! wuf!` says `wuf! wuf! woof!`. Here is how
we can do it:

``` javascript
class Labrador extends Dog {
  constructor(name) {
    super(name); 
  }

  bark() {
    console.log("wuf! wuf!");
    console.log("woof!");
  }

  playWithKids() {
    console.log("playing with kids! wuf! wuf!")
  }
}

var leo = new Labrador("Leo");
leo.bark();
```

Pretty simple. We can even use the definition from the parent class
by doing the following:

``` javascript
class Labrador extends Dog {
  constructor(name) {
    super(name); 
  }

  bark() {
    super.bark();
    console.log("woof!");
  }

  playWithKids() {
    console.log("playing with kids! wuf! wuf!")
  }
}

var leo = new Labrador("Leo");
leo.bark();
```

That was again, blazingly simple. I don't even know how to do that
in plain old JavaScript.

## Getters

There is one more feature that I want to write about, the new getter syntax.
Let's start with an example `User` class:

``` javascript
class User {

  constructor(firstName, lastName, age) {
    this.firstName = firstName;
    this.lastName  = lastName;
    this.age       = age;
  }

}

var user = new User("Igor", "Sarcevic", 24);
```

Now, let's say there is a need to get the full name of the user. We can define
a method called `fullName` like this:


``` javascript
class User {

  constructor(firstName, lastName, age) {
    this.firstName = firstName;
    this.lastName  = lastName;
    this.age       = age;
  }

  fullName() {
    `${this.firstName} ${this.lastName}`
  }
}

var user = new User("Igor", "Sarcevic", 24);

console.log(user.fullName());
```

Note: I used the sexy new string template syntax, go look it up, you won't regret it. :D

The `fullName` method is simple but it can bother you that you must
to append the function invoking brackets `user.fullName()` every time you need to know 
the full name of the user. Luckily, we can user getters:

``` javascript
class User {

  constructor(firstName, lastName, age) {
    this.firstName = firstName;
    this.lastName  = lastName;
    this.age       = age;
  }

  get fullName() {
    `${this.firstName} ${this.lastName}`
  }
}

var user = new User("Igor", "Sarcevic", 24);

console.log(user.fullName);
```

In the above example pay attention to the addition of the `get` keyword
and the removal of the brackets when the getter was invoked `user.fullName`.

## Final words

I can only say that I fell in love with the new OOP style. Finally, JavaScript
can be as expressive as the other languages in its category.

But it makes me wonder what is the future of CoffeeScript?
