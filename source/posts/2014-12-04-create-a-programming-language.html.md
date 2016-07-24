---
id: 969c25e8-7360-4190-9ed4-0813dd8fd950
title: Create a programming language
tags: general
blog: blog
image: lambda.png
---

I have been programming for a long time. Probably much longer than I  want to admit. Yet, for a long time, there was something mysterious about the way I created my programs. Yes, I could write a lot of stuff in programming languages, but I had no idea how to create a programming language itself. 

With time, and some healthy logic, I kinda deducted how that process could be achieved, but at the beginning of this year I actually wrote a programming language prototype of my own. This is a story that shows how I crated a Lisp like programming language prototype called Bracket.

## Programs are only strings in a file

What I mean by this title, is that from the standpoint of the interpreter or a compiler a program written in a programming language is just a string. It needs to read in from a file, broken down to little pieces, and then reassembled into meaningful actions.

Let's say I have a file named `example.br` that contains the following source code written in my new programming language.

``` lisp
(+ 1 2 (* 2 3 ))
```

Which, if you are familiar with Lisp, should evaluate to `9`. The first thing our interpreter needs to do with the above *string* is to break it into small logical elements. This process is usually called parsing which result should resemble something like the following.

``` ruby
[ "(", "+", "1",  "2",  "(", "*",  "2",  "3", ")", ")" ]
```

Is this just an array of strings? Exactly! A simple array of strings. Onto the next step.

## Turning lists into lists

This will be a mind boggling task. I will transform the above list of strings into a list of lists of strings. 

My objective is to recognize the `"("` and `")"` elements in the array, remove them, and place the elements in the between them into a new array.

This task will output the following result.

``` ruby
[[ "+", "1",  "2",  ["*",  "2",  "3"]]]
```

## Recognizing the types of data

There is one thing missing before we start to calculate the result of the above expression. We need to transform the string representation of the numbers into actual numbers.

This one is actually quite easy. Simply turn every element except the first one into a number.

``` ruby
[[ "+", 1,  2,  [ "*",  2,  3]]]
```

I skipped the first element in every array, because it is a name of a function, not data.

## Calculating the result

Now is the big finally. Here is how we will do it.

We will take the most deeply nested array from the above array, and calculate its value. The most deeply nested array in the above example is

``` ruby
 [ "*",  2,  3 ]
```

We must notice that it has no sub arrays. In other words we can just execute a function named `product` and pass it all the elements from the above list.

``` ruby
product(2, 3)        # => 6
```

And yes the result is `6`. Now we take that number and pluck it back into the original array.

``` ruby
[[ "+", 1,  2, 6]]
```

And repeat the process again, until we have a sub-arrays in our array.

``` ruby
[9]
```

And then read out the result as the first thing in our array. That is 9. Eureka!

## Summary

This is a very rough sketch that should give you an idea what an actual interpreter does. Of course it is much smarter, and can recognize other datatypes, not just numbers, but at its core it does something similar to this.

Also you can check out my source code [at GitHub](https://github.com/shiroyasha/bracket).

Happy hacking!
