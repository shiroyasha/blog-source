---
title: Arithmetic in the Shell
date: 2015-03-05
tags: shell
image: arithmetic.png
---

I remember the first time I tried to use the shell.
It was weird that I had to type in things and not just
click around to get things done. But gradually I got
used to it, and after a while it became my primary way
to interact with my computer.

It didn't pass much time till I figured out that the
commands that I am typing in are actually part of a
programming language named Bash. That of course changed
everything! Starting from that moment I could combine
the thing I love ( programming ) with the boring chore
of keeping my system in a sane condition. That moment
a new kind of passion for computers was born in my hearth.

But wait! If Bash is a programming language it must be
able to count and do basic arithmetic. This article is
precisely about that &mdash; calculations in the shell.

## Expr
This task is actually really simple, but there are as always
in Unix, several ways to do it. The oldest method is to use
`expr` to evaluate expressions. For example to add 2 and 4 
we can write the following:

``` sh
$ expr 2 + 4
6
```

This seems really easy, but there is a catch. If you try to
multiply numbers using `*` Bash will throw you back an error:

``` sh
$ expr 2 * 4
expr: syntax error
```

In this case Bash sees `*` as wildcard operator so you must
use a backslash before the asterisk sign:

``` sh
$ expr 2 \* 4
8
```

At this point you will probably try to surround the expression
with quotes, but that will also fail:

``` sh
$ expr "2 * 4"
2 * 4

$ expr '2 * 4'
2 * 4
```

Apart from this little annoyance, `expr` is quite powerful. It can
even do boolean arithmetic:

``` sh
$ expr 2 \< 4
1

$ expr 4 \< 2
0
```

## Arithmetic expansion

There exists a better alternative for `expr` but is unfortunately
not available in the original Bourne Shell only in the POSIX
compliant one &mdash; arithmetic expansion.

It can also, like `expr`, take an arithmetic expression, but 
instead of printing out the result, it will substitute itself with the
resulting value.  To print out the result we must use `echo` or `print`. For
example to multiply 2 and 4 we can write the following:

``` sh
$ echo $(( 4 * 2 ))
8
```

Without an `echo` this command would fail with:

``` sh
$ $(( 4 * 2 ))
sh: 1: 8: not found
```

As you can see in the above example, Bash tried to execute the result
of the expression as a standard command.

Note: There is an older variant of arithmetic expansion that uses the
following less verbose form `$[ 1 + 4 ]` but is now deprecated.

## Euclid's Algorithm in the Shell

Now let's do something more challenging and try to implement Euclid's
greatest common divisor algorithm in a shell script. 

Note: This part will be a little bit advanced and will require you to
be familiar with other common things in Bash like loops and variables.

Let's start by creating a shell script and giving it executable
permissions:

``` sh
$ touch gcd.sh
$ chmod +x gcd.sh
```

My goal is to invoke my script with two command line arguments and
expect it to print out the greatest common divisor like this:

``` sh
$ ./gcd.sh 14 4
2
```

To achieve this we will first need to capture the two incoming numbers
with `$1` and `$2`:

``` sh
#!/bin/sh

a=$1
b=$2
```

The remainder of the script is the basic implementation of the Euclid's
algorithm that I presume every programmer recognizes:

``` sh
#!/bin/sh

a=$1
b=$2

while [ $b -ne 0 ]; do
  remainder=$(( $a % $b ))
  a=$b
  b=$remainder
done

echo $a
```

Note: Shame on you if you don't recognize the following algorithm, 
go and Google it. This is probably the most basic algorithm out there.
Also, sorry for the harsh words :3

## Final words

I hope you enjoyed this article and also that I have shown you
something new and exciting.

Stay awesome!

By the way, I started using drawing tablet instead of the old 
paper + photo + gimp approach. I hope you like this new art style.
