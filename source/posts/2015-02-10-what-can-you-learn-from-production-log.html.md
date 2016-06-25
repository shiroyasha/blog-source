---
title: What can you learn from production.log?
tags: shell
image: what-can-you-learn-from-production-log.png
---

Many developers fail to realize that using the basic Unix tools, you can find
on any server, you can find and collect valuable data from your logs. Often the
data you need can be found without using any external services, including but
not limited to service measurements.

_This is a start of a series of posts that will try to show some of the nice
things you can achieve with the Rails log from the command line._

## The basics

Let's star with the simplest one &mdash; following the incoming logs:

``` sh
tail -f log/production.log
```

We could of course show the complete log with `cat`, but often it is far longer
than we would expect and following the logs tends to be much nicer. On the other 
hand `cat` can be handy when combined with `grep` and `tail`. 

## Filtering

The first thing we want to learn is to filter the log from the information
we don't need for the current measurement. Filtering is all about recognizing
the patterns in the text and cutting out everything that doesn't match it.
A common thing is to display only the CRUD request logs, or to filter everything
out except database actions.

A nice scheme for creating complex filters (and the one we will be 
using in the examples) is the following:

``` sh
cat log/production.log | <filters> | tail
```

In the above command the `cat` command _pushes_ the logs into the 
filters, and the `tail` command shows a portion of the result. An
alternative for the `tail` - that shows the end of the results - can
be the `head` command that shows the start. By default, both commands
display only 10 results, but can be tweaked to show more with the `-n`
option. For example to list the last 20 lines we can use the following
scheme:

``` sh
cat log/production.log | <filters> | tail -n 20
```

But enough with the boring details, let's define a filter. The following
example shows only incoming `POST` requests.

``` sh
cat log/production.log | grep 'method=POST' | tail -n 20
```

In the above example we used the `grep` command that returns only the lines
that have the provided string or regular expression in them. We can also
combine multiple `grep` commands, where the second `grep` will only work
on the lines that the first `grep` returned.

For example, the following command shows only the `POST` requests that had
a HTTP status `200` as their answer:

``` sh
cat log/production.log | grep 'method=POST' 
                       | grep 'status=200' 
                       | tail -n 20
```

Similarly to the previous ones, we can easily show only the logs that were
created yesterday:

``` sh
cat log/production.log | grep 'method=POST' 
                       | grep 'status=200' 
                       | grep 'time=2015-02-10' 
                       | tail -n 20
```

As the final example I will demonstrate something more complicated. We will list
only the POST requests that had a duration longer than 10 milliseconds.
Unfortunately, we can't use the previous technique anymore because the string
that we are matching are different on each line (somewhere the duration is 13
milliseconds, somewhere it is 114 milliseconds...).

Fortunately, we can use regular expressions with the `grep` command.
What we need is actually more than one digit in the duration that will
give us a number larger or equal to 10. To match a digit we will use the
`[0-9]` notation, and to match 0 or more of them we will write `[0-9]*`.

``` sh
cat log/production.log | grep 'method=POST' 
                       | grep 'duration=[0-9]*[0-9][0-9]' 
                       | tail -n 20
```

In the above example we used `[0-9][0-9]` to match two digits and `[0-9]*`
to match the remaining.


## Final words

I hope you enjoyed this tutorial, I will give my best to finish the next
one soon, where I will be talking about counting.

Happy hacking!
