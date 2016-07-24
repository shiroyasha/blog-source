---
id: 4509c73d-7627-4e4d-a126-2a994a85c74d
title: Select and count your production.log!
tags: shell
image: select-and-count-your-production-log.png
---

Last time, I have demonstrated how we can put together simple filters
to show only the lines we are interested in. This time I will show 
you how you can manipulate these lines and select only the parts you
really need.

_This post is the continuation to the 
[What can you learn from production.log?](/what-can-you-learn-from-production-log.html)
, and will continue where the last one stopped. Please read that post,
before continuing to this one._

## Enumeration and counting

You have finally managed to put together the right combination of
`grep` filters to only get the lines you want. But what can you do
with it? 

What I like to start with is a simple line count. For example, I can
easily count the number of `POST` requests my server has received for
this day, by executing the following filter:

``` sh
cat log/production.log | grep 'method=POST' 
                       | grep 'time=2015-02-16' 
                       | wc -l
```

The above command should be pretty familiar by now except the last
command in the pipe. To count lines, we can use the word count
command `wc` and pass it the option `-l` to get the number of
lines.

Similarly to the above example we can enumerate the lines by using
the `nl` command:

``` sh
cat log/production.log | grep 'method=POST' 
                       | grep 'time=2015-02-16' 
                       | nl
```

This command doesn't look so useful as the above, but it can come handy
for orientation when you share the output with a friend or when you 
combine it with some other interesting commands.

## Manipulating the lines

Now let's do something more interesting. You have probably noticed 
that while we do remove the unnecessary lines, we do not remove
the unnecessary noise from within the lines. For example let's say
that a query for today's requests returned the following output:

``` sh
method=POST path=/user format=*/* controller=users action=create status=200 duration=19.4 view=0.00 db=3.91 time=2016-02-16 16:48:37 +0000
method=GET path=/user format=*/* controller=users action=create status=200 duration=19.4 view=0.00 db=3.91 time=2016-02-16 16:50:37 +0000
method=POST path=/user format=*/* controller=users action=create status=200 duration=19.4 view=0.00 db=3.91 time=2016-02-16 16:52:12 +0000
```

Ugh, that is a little overwhelming, especially if I only want to
know the path and the method for example. Luckily, we can use
`awk` to help us with pruning the above lines. But first let's see
how `awk` works on a simpler example. This command is really handy
for reorganizing and cutting of unnecessary parts of lines. Let's
use the following line, and show only the first and the last entry.

``` sh
dog cat fish
```

By default, `awk` separates the fields in a line on the and gives
them back to us in the form of `$1`, `$2`, `$3`... To show only the
first and the last entry, execute the following command:

``` sh
echo "dog cat fish" | awk '{ print $1 $2 }'
```

In the above example I only used `echo` as a mean to push something
into the `awk` command, but it can work on any output. But wait!
This command has the following output, that is not what we want:

``` sh
dogfish
```

Yes, we also have to put a separator between them:

``` sh
echo "dog cat fish" | awk '{ print $1 " " $2 }'
```

We can of course put any string between them, like an arrow:


``` sh
echo "dog cat fish" | awk '{ print $1 " ---> " $2 }'
```

We can also reorganize the output:


``` sh
echo "dog cat fish" | awk '{ print $3 " ---> " $1 " ---> " $2 }'
```

That will give us:

``` sh
fish ---> dog ---> cat
```

Enough with the examples! Let's get back to our original objective
&mdash; showing only the method and the path of today's request:


``` sh
cat log/production.log | grep 'method=POST' 
                       | grep 'time=2015-02-16' 
                       | awk '{ print $1 " " $2 }'
```

Hooray, this just what we needed!

``` sh
method=POST path=/user 
method=GET path=/user
method=POST path=/user
```

## Final words

I hope you enjoyed this tutorial, I will give my best to finish the next
one soon, where I will be talking about uniqueness and sorting.

Happy hacking!
