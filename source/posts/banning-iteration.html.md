---
title: Banning Iteration
date: 2015-10-01
tags: programming
image: banning-iteration.png
---

In the last couple of months I had the honor to be a mentor to several students
that were taking part in our summer internship program. I had a ton of fun,
learning not only about programming but also about the art of teaching other
programmers and helping them overcome their fear of complexity.

Even though they were all exceptional computer science students, a common
pattern was their over dependency on the good old `for` loop. This was of course
understandable. The most popular teaching languages on our local universities
are Java and C/C++. None of which, in my opinion, are good enough to prepare the
students for the modern web and the level of abstraction required for working on
bigger projects.

# Basic iteration

One of the first thing any computer science undergraduate learns is the `for`
keyword. The magic word that can repeat common tasks and can even make our
programs run forever. Here is a simple Java example that counts to ten:

``` java
for(int i=0; i < 10; i++) {
  System.out.println(i);
}
```

Another common thing is iterating over a list of values. For example, to list
the age of every user in an array, we could write:

``` java
int[] ages(User[] users) {
  int[] result = new int[users.lenght];

  for(int i=0; i < users.length; i++) {
    result[i] = users[i].getAge();
  }

  return result;
}
```

# The issue with iterating with a for loop

Take a look at the above example that transforms the array of users into an
array of numbers. It seems like a lot of work for a simple idea. Here are the
mental steps that you need to implement such a method:

1. Create an array that will hold the results
2. Set the capacity of the array to match the number of users
3. Create an iterator named `i` that will hold the current index of the array
4. Setup an iteration construct that will loop over every user in the array
5. Limit the iteration when the iterator `i` is the same as the number of users
6. Increase the iterator `i` after each step in the iteration
7. In every iteration lookup the user on the `i-th` location in the array
8. Get the age of that user
9. Save the age value in the result array on the i-th place
10. When the iteration is over return the result to the caller

Well... this was a lot of typing. A lot of place to make an error while
writing the implementation.

Luckily, this is the worst possible way to achieve our goals.

# Eliminating the redundant `i` iterator

Many students learn the `for(int i=0; i < N; i++)` construct by heart and
replicate everywhere, replacing only the value of `N` with an appropriate value.
But why would we do this? Automating things is one of the core principles of our
craft. We should never let the computers make a fool of us!

Lets switch from arrays to lists and use the newer for loop syntax:

``` java
List<Integer> ages(List<User> users) {
  List<Integer> result = new ArryaList<User>();

  for(User user : users) {
    result.add(user.getAge());
  }

  return result;
}
```

The above code looks nicer. Lets write down the mental steps for this
implementation.

1. Create an array that will hold the results
2. Setup an iteration construct that will loop over every user in the list
3. Get the age of the user in each iteration
4. Save the age value in the result list
5. When the iteration is over return the result to the caller

Much nicer and easier to understand. Here are some steps that we don't have to
worry about anymore:

1. Set the capacity of the array to match the number of users
2. Create an iterator named `i` that will hold the current index of the array
3. Limit the iteration when the iterator `i` is the same as the number of users
4. Increase the iterator `i` after each step in the iteration
5. In every iteration lookup the user on the `i-th` location in the array
6. Save the age value in the result array on the i-th place

# Language switch

Unfortunately, vanilla Java can take us only this far. It is still possible to
conceptually improve the above, but it takes a lot of effort and it is against
the flow of the language.

Introducing Ruby! The language that can easily take us to the next level.

First let's rewrite the above snippet in ruby:

``` ruby
def ages(users)
  result = []

  for user in users do
    result.push(user.get_age())
  end

  return result
end
```

A note for experienced Ruby programmers: I know you want to tear you eyes out,
but please bare with me. The above monstrosity is only for demonstration
purposes.

Lets continue!

# Eliminating the result set

First lets remove the non-typical `for` loop. Ruby programmers always prefer
the `each` method over the `for` operator.

``` ruby
def ages(users)
  result = []

  users.each do |user|
    result.push(user.get_age())
  end

  return result
end
```

While the above snippet looks quite nice, it is still far from perfect! Notice
the redundant `result` list that we explicitly create for every list
transformation.

Introducing the `map` method. It is very similar to the `each` method with a
simple but very important feature. It creates the result set instead of us and
places the result of every iteration in the appropriate spot.

``` ruby
def ages(users)
  return users.map do |user|
    user.get_age()
  end
end
```

Lets review the mental steps in the above code snippet:

1. Setup an iteration construct that will loop over every user in the list
2. Get the age of the user in each iteration
3. When the iteration is over return the result to the caller

The following steps are no longer needed:

1. Create an array that will hold the results
2. Save the age value in the result list

# Eliminating the return statements

The last step that returns the value of the calculation is usually not needed in
ruby. The language is smart enough to return the last calculated value from any
method.

``` ruby
def ages(users)
  users.map do |user|
    user.get_age()
  end
end
```

This snippet reduces the number of mental steps to only two steps.

1. Setup an iteration construct that will loop over every user in the list
2. Get the age of the user in each iteration

# Making the code nicer and more idiomatic

A true Ruby programmer would never write a `get_age()` method. Explicit actions
are the relic of the past. Welcome to the age of declarative programming.

To access the `age` attribute of the method we can simply write `.age`. Also
parenthesis are optional. We will optionally remove them :)

``` ruby
def ages(users)
  users.map do |user|
    user.age
  end
end
```

The above method could even be shorter. A one liner. In ruby, the `do ... end`
block is equivalent to curly braces.

``` ruby
def ages(users)
  users.map { |user| user.age }
end
```

# Going even further by eliminating an explicit get

You probably thought that we finished and declared it finished. However, there
are still couple of things that could be done. Notice that in the above example
we explicitly read out the `age` value from every user.

Ruby has a shorthand method for this. We call it `pluck`.

``` ruby
def ages(users)
  users.pluck(:age)
end
```

The above code snippet is equivalent to the previous one, but with one less
mental step. Here is the current list of needed mental steps:

1. Collect the age of every user

The following step is no longer needed:

1. Setup an iteration construct that will loop over every user in the list

With the above code snippet you would make a good friend with any Ruby
programmer. I am always happy to drink a couple of bears with programmers who can
write code like this. Just saying...

# Language switch number 2

We are still not finished! Ruby is a great language but it has its limitations.

But what can we improve here you ask. Come and see. Introducing Haskell!

First lets start by rewriting the above snippet into executable Haskell code.

``` haskell
ages users =
  map age users
```

# Eliminating the arguments

Haskell is quite smart when it comes to handling function arguments. It can pass
the arguments the end of functions body. The following is equivalent to the
above:

``` haskell
ages = map age
```

It looks weird. I know! But you get used to it :)

Finally lets review the necessary mental steps for this implementation:

- None. The above code is practically effortless.

# Conclusion

We came a long way from our original implementation in Java. Just for
comparison here are two identical implementations:

``` java
int[] ages(User[] users) {
  int[] result = new int[users.lenght];

  for(int i=0; i < users.length; i++) {
    result[i] = users[i].getAge();
  }

  return result;
}
```

``` haskell
ages = map age
```

I hope you, beloved reader, understand why I think that Java is far from ideal
when it comes to teaching the next generation of engineers and for the
challenges that our craft presents.
