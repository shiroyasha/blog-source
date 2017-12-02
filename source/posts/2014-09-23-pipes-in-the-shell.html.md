---
id: f6960503-7724-4ddd-be83-fcca0c000e01
title: Pipes in the shell
tags: shell
image: pipes-in-the-shell.png
---

Here is a story of my typical work session in the shell. It starts by a wish to make the computer execute some of my commands. For example, I want to list all the files in the current directory. From prior knowledge I know that the `ls` command does exactly that, so I use it, and get the desired output. But I am out of luck, the current directory contains too many entries and I just can't scroll so much up in the history.

READMORE

I also know that there is this nifty little command called `more` that paginates any text that it receives on the input. If only I could just somehow connect the two.

Pipes to the rescue! With them I can connect any two programs together and make them do things they couldn't on their own. So I get the following

``` sh
ls | more
```

The strange little vertical line between `ls` and `more` is called the pipe operator. It connects the output of the first program with the input of the second. In other words it collects the text that the `ls` printed and send it to `more` program for pagination.

## Pipes are handier than you think

The above example probably gave you a nice ahaa! moment, but at the same time you could have thought that it can be useful only rarely. Here are some examples that shall show you the power behind this simple vertical line.

## Searching for a file by their title

The `ls -l` command prints files line by line, and the `grep` command shows only the lines that contain a given string. Lets pipe them together to search for files that have `cat` in their name.

``` sh
ls -l | grep "cat"
```

A variation of the above would be to show all the files that don't contain `cat` in their title.

``` sh
ls -l | grep -v "cat"
```

## Counting files in a directory

The word count command `wc`  counts the number of words. If you also add the `wc -l` it will count the number of lines.

``` sh
ls -l | wc -l
```

Going even further, you can count the number of files that contain the `cat` string in their title. To do that we need to pipe even more commands, but it is still quiet easy

``` sh
ls -l | grep "cat" | wc -l
```

## Finding processes by their title

The `ps aux` command lists all the active processes on the machine. So to list all the running `chrome` instances, we can pipe together `ps aux` and `grep`

``` sh
ps aux | grep "chrome"
```

To count them we can use `wc -l`

```sh
ps aux | grep "chrome" | wc -l
```

## Summary

The pipe is one of the easiest and most versatile operators that you have in the shell. If this is the first time you read about them, you can prepare for a wide range of interesting command combinations and the joy you get from creating them.
Also you can start to appreciate the simplicity end elegance that the shell gives you by combining little building blocks to solve complex problems.
