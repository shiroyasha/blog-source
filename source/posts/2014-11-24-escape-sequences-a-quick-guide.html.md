---
title: Escape Sequences - A Quick Guide
tags: example
image: escape-sequences-a-quick-guide.png
---

Two years ago I thought I knew a lot about the Linux command line. Then I started digging deeper. Replaced Bash with Zsh, learned about jobs, started writing shell scripts, and even ditched Sublime text in favor of editing with command line Vim. Again I thought I know a lot about the Linux command line. Then I started digging deeper again...

A few weeks ago I wrote a blog post that described [how to create progress bars for command line application](http://shiroyasha.svbtle.com/processbar-for-console-applications). There I have described how to stay on the same line, and thus simulate a filling progress bar. That blog post made me wonder if there is a way to change multiple lines of text at once. I started looking for a solution, but what I found was more amazing than I ever thought it would be.

The thing I have found was a way to insert escape characters in the output of your commands that would tell the terminal to do all sorts of crazy things, like move your cursor up several lines, blink the output, change the color, etc...

Like the tittle of the blog posts describes, escape sequences start with pressing the `ESC` key on your keyboard followed by a sequence of actions you want your terminal to execute. For example inserting the following would move your cursor up 5 lines and write "Hello":

``` sh
ESC  [  5  A Hello
```

Before I start explaining the actions in details, I should show you how to output these commands from a program. To output the `ESC` character write the `\e` sequence. That way the above becomes the following in ruby:

``` ruby
puts "\e[5AHello"
```

## Movement

The four basic movements are the following:

``` ruby
puts "\e[3A" # up - moves 3 lines up
puts "\e[6B" # down - moves 6 lines down
puts "\e[2C" # forward - moves 2 characters forward
puts "\e[1D" # backward - moves 1 character backward
```

Moving to the beginning of lines:

``` ruby
puts "\e[2E" # move to the beginning of 2 lines down 
puts "\e[4F" # move to the beginning of 4 lines up
```

Moving to columns:

``` ruby
puts "\e[16F" # move to 16th column
```

Precise movement can be achieved with `\e[n;mG` where `n & m` represent the n-th row and m-th column.

``` ruby
puts "\e[3;9G" # moves cursor to the 3rd row 9th column
```

Scrolling can be achieved with the the following:

``` ruby
puts "\e[2S" # scroll 2 lines up
puts "\e[4T" # scroll 4 lines down
```

## Erasing the screen

The J and K keys are responsible for clearing portions of the screens. To clear the whole screen, write the following:

``` ruby
puts "\e[0J" # Clear screen from cursor to the end
puts "\e[1J" # Clear screen upto the cursor
puts "\e[2J" # Clear entire screen
```

Clearing the line is done with the K command:

``` ruby
puts "\e[0K" # Clear line from cursor to the end
puts "\e[1K" # Clear line upto the cursor
puts "\e[2K" # Clear entire line
```

## Cursor operations

To show and hide the cursor

``` ruby
puts "\e[?25h" # show cursor
puts "\e[?25l" # hide cursor
```

To save the position of the cursor and then restore it back

``` ruby
puts "\e[s" # save the position of the cursor
puts "\e[u" # restore the position of the cursor
```

## Graphical elements

The most complex command you can send to a terminal with the escape sequence is the Select Graphic Rendition parameter that is issued with the `m` command. The following scheme describes how to pass arguments to the action.

``` ruby
puts "\e[a;b;c;dm" # where a, b, c, d are parameters
```

Notice how the parameters are delimited with the ; symbol. You can write as many parameters as you want. Here are some nice examples:

``` ruby
puts "\e[31mtest"        # output red test
puts "\e[31;47mtest"     # output red test with white background
puts "\e[1;4;31;47mtest" # output red on white, bold, underlined test
```

A great resource for finding arguments for the above command is [the Wikipedia article describing escape sequences](http://en.wikipedia.org/wiki/ANSI_escape_code#CSI_codes).

## Summary

These control characters may seem complicated at first glance, but once you play around with them they become simple and powerful. With this knowledge you can finally understand the PS1 environment variable, have beautiful command line applications, or as in my case, make a nyancat run through your screen representing the progress of your test suite.

Happy hacking!
