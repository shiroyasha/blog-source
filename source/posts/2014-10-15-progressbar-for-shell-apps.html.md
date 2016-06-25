---
title: Progress bar for shell apps
tags: shell
image: lol.png
---

Downloading a file, backing up your database, or installing a package for your system are all instances of long lived processes that we encounter daily. When such a process takes a long time to finish, it is always nice to give some kind of visual cue to the user.

A nice and space efficient way to achieve the previous is to use a progress bar or a display counter. This tutorial aims to help you create such an output for a console application.

The hardest part in creating such an output is to figure out how to clear the current line in the output and replace it with another. Well, there is a clever trick involved. Instead of using an `\n` at the end of the string that is printed to `stdout`, you can use the `\r` escape value. These two are familiar values but the first jumps to the start of the line and moves one line down, while the second only moves to the beginning of the line and thus rewrites that line when a new output arrives.

Here is a nice little script that will display a progress bar &ndash; written in the ruby programming language, but easily translatable to any other.

``` ruby
def print_progress_bar(finished_percent)
  finished = "#" * finished_percent
  empty    = "-" * (100 - finished_percent)

  print "\r[ #{finished}#{empty} ] #{finished_percent}% "
end

(0..100).each do |count|
  print_progress_bar(count)
  sleep 1
end
```

## Full line progress bars

The above code snippet works great, **if** your terminal is wider than ±100 columns. Otherwise it just breaks up your lines and looks ugly. On the other hand if your terminal is much wider than 110 columns the output 
is again strange because it leaves much of the space unfilled.

![Full line progress bar](https://d23f6h5jpj26xu.cloudfront.net/2juf16zexpkqng_small.png)

Here is a solution. If we execute the `tput cols` command it will return us the width of the terminal window in column numbers and we can use it to cleverly calculate the length of our progress bar. The improved &mdash; `tputs` using &mdash; code snippet follows

``` ruby
def print_progress_bar(finished_percent)
  fixed_space = 9 # for braces and number

  width = `tput cols`.to_f - fixed_space

  finished_count = ((finished_percent*width)/100).ceil
  empty_count    = width - finished_count

  finished = "#" * finished_count
  empty    = "-" * empty_count

  print "\r[ #{finished}#{empty} ] #{finished_percent}% "
end

(0..100).each do |count|
  print_progress_bar(count)
  sleep 1
end
```
