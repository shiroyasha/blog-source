---
id: 7c1cd63c-0892-43d0-996a-b4b4a6e544b5
title: Sorting your production.log
tags: shell
image: sorting-your-production-log.png
---

Many developers fail to realize that by using the basic Unix tools, you can find
on any server, you can find and collect valuable data from your logs. Often the
data you need can be found without using any external services, including but
not limited to service measurements.

_This is the continuation of the series where I show how to collect
valuable data from your production.log. Please read the 
[previous posts](/select-and-count-your-production-log.html)
if you haven't already_

## Basic Unix sorting

In this article I want to show you how to sort your data using
the `sort` Unix command. With that you can order the routes by 
response time, or to count them and show a list of most frequently
visited. But first let's see how the `sort` command works.

Let's start with a file `animals.txt` that has the following content:

``` txt
dog
cat
fish
```

If you call `sort` on this file the output will be the following:

``` sh
$ sort animals.txt
cat
dog
fish
```

As you can see in the above output, the `sort` command orders the
lines alphabetically. To show the reverse order:

``` sh
$ sort -r animals.txt
fish
dog
cat
```

You can also sort numerically. For example if you have a file called
`numbered-animals.txt` with the following content:

``` txt
117 cat
1 fish
10 dog
```

You can sort it with the following command:

``` sh
$ sort -n numbered-animals.txt
1 fish
10 dog
117 cat
```

Please note that if you leave out `-n` your output will be the same
in some cases, but not always. For example:

``` sh
$ sort -n numbered-animals.txt
10 dog
117 cat
1 fish
```

We can of course order by other words other than the first one in the
line. Using the `-k` option we can tell `sort` which field it to use.
Let's look at the following `example.txt` file:

``` sh
a=abc b=999
a=abd b=462
a=abf b=517
```

To sort using the `b=` part we can invoke `sort` with the `-k 2` option
to select the second word in the lines:

``` sh
$ sort -k 2 example.txt
a=abd b=462
a=abf b=517
a=abc b=999
```

But, the `-k` option doesn't stop there. We can also select the 
character from which we want to start sorting. For example to cut
of the first `3` characters in the `b=462` and get `62` we would
write `-k 2.4` option, and thus sort only using the last two digits:

``` sh
$ sort -k 2.4 example.txt
a=abf b=517
a=abd b=462
a=abc b=999
```

## Sorting logs by response time

Now let's use the above knowledge to sort the routes from fastest to
slowest. Let's use the following example:

``` sh
method=GET path=/user format=*/* controller=users action=create status=200 duration=4.2 view=0.00 db=3.91 time=2016-02-16 16:50:37 +0000
method=POST path=/user format=*/* controller=users action=create status=200 duration=2.4 view=0.00 db=3.91 time=2016-02-16 16:48:37 +0000
method=POST path=/user format=*/* controller=users action=create status=200 duration=56.4 view=0.00 db=3.91 time=2016-02-16 16:52:12 +0000
```

The only thing now we have to do is to count the location of
the things we want to sort. In this example we are interested
in the `duration=<number>` part of the lines. The `duration` is
the 7th word on the line and the numbers start at the 10th place
in the word. Now it is easy to conclude that we need the `-k 7.10`
option in our sort command.

The other option we want to use is the `-n` option to sort the lines
numerically.

``` sh
$ cat production.log | sort -n -k 7.10 
method=POST path=/user format=*/* controller=users action=create status=200 duration=2.4 view=0.00 db=3.91 time=2016-02-16 16:48:37 +0000
method=GET path=/user format=*/* controller=users action=create status=200 duration=4.2 view=0.00 db=3.91 time=2016-02-16 16:50:37 +0000
method=POST path=/user format=*/* controller=users action=create status=200 duration=56.4 view=0.00 db=3.91 time=2016-02-16 16:52:12 +0000
```

## Final words

I hope you enjoyed this tutorial, I will give my best to finish the next
one soon, where I will be writing about unique lines.

Happy hacking!
