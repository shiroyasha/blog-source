---
id: ae4cc0c4-0e9d-4d23-a51b-59ee3681bfa8
title: Coreutils that you might not know
date: 2017-05-21
tags: programming
image: 2017-05-21-coreutils-that-you-might-not-know.png
---

I've used Linux as my primary operating system for well over ten years, yet I
still stumble upon things that are completely unknown to me. For example,
several days ago, I wanted to display a formated table in my terminal.

``` txt
# I had a long list of values resembling the following:

id,name,count
31232,test-1,21
31,window,2
2121,update-attributes,432

# and I wanted to produce a table for easy scanning:

id     name               count
31232  test-1             21
31     window             2
2121   update-attributes  432
```

I know that in Ruby, I have an excellent library
[Terminal Table](https://github.com/tj/terminal-table) for generating nice
terminal tables, however, parsing the input, mapping the values and writing a
Ruby script just for this task seemed like a huge overhead. After googling
around for a quick and easy solution, I've learned that there is already a
readily available tool in my Linux environment &mdash; column.

``` bash
$ cat data.txt | column -t -s ','

id     name               count
31232  property-a         21
31     window             2
2121   update-attributes  432
```

Whoa! That was super simple. I was baffled by the fact that this program was
part of the standard coreutils package, and yet I've never used it. So I
wondered what else is part of coreutils that I don't know about. I've found
several interesting and usable tools.

For example, did you know that you have a built in calendar?

``` bash
$ cal

      May 2017
Su Mo Tu We Th Fr Sa
    1  2  3  4  5  6
 7  8  9 10 11 12 13
14 15 16 17 18 19 20
21 22 23 24 25 26 27
28 29 30 31

$ cal -3

                            2017
       April                  May                   June
Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa
                   1      1  2  3  4  5  6               1  2  3
 2  3  4  5  6  7  8   7  8  9 10 11 12 13   4  5  6  7  8  9 10
 9 10 11 12 13 14 15  14 15 16 17 18 19 20  11 12 13 14 15 16 17
16 17 18 19 20 21 22  21 22 23 24 25 26 27  18 19 20 21 22 23 24
23 24 25 26 27 28 29  28 29 30 31           25 26 27 28 29 30
30
```

Or, did you know that you can factor numbers with the `factor` program?

``` bash
$ factor 234123421341
234123421341: 3 67 1601 727541

$ factor $(date +%s) # factor current timestamp
1495329393: 3 19 47 558167
```

Or, that you can find out how many terabites are in `4123412312312` bytes:

``` bash
$ numfmt --to=iec 4123412312312
3.8T
```

Or that there is a hardcore version of `rm` that makes it much harder to
retrieve deleted files:

``` bash
$ shred a.txt
```

So many interesting things to learn! I encourage you to read through the
[documentation](https://www.gnu.org/software/coreutils/manual/coreutils.html#toc-System-context-1)
and update your knowledge on these wonderful tools that are installed
out of box on our modern Linux distributions.
