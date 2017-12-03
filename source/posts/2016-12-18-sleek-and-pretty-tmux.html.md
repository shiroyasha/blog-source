---
id: ef018655-316e-4147-8cd9-af78a60edc1b
title: Sleek and Pretty Tmux
date: 2016-12-18
tags: programming
image: tmux.png
---

A good craftsman is known by his tools. He never uses the biggest hammer in
his shed to fix a little bump, neither does he use a duct tape to join together
the most fragile parts of his craft. For a good craftsman both a hammer and
a duct tape are vital elements of his toolbox. He has a good eye, and the
intuition to choose the most appropriate tool for every situation he faces.

READMORE

A master craftsman goes even further. He knows that often there is no good
enough tool, and that he needs to invest his time to create tools in advance,
tools that will make him ready to tackle even grander projects in the future. He
cherishes his tools and keeps them sharp and clean.

The master craftsman can seem orders of magnitude faster and smarter, but in
reality he is just like everyone else, except that he has a better toolbox.

I believe the same is true for us software developers.

## Multiplexing a terminal

Long ago, I choose the terminal as my default work environment. I strongly
believe that in the Unix world there is simply no better alternatives to a well
customized Vim, good terminal emulator, and customizable command line tools that
fit nicely in an automated environment.

Splitting my work environment in half and creating new work environments fast
and on demand is very important to me. `screen` and `tmux` are excellent
candidates, where the later is the more recent and feature rich copy of the
first.

`tmux` is great, but my first encounter with it wasn't the happiest. The
keyboard shortcuts were simply horrible for my taste. I was forced to hit
`Ctrl + b + c` just to create a new window. My fragile fingers are not good
enough for this, so I simply gave up and stopped using it.

However, I really liked the speed and versatilities that it offered in my
environment. I knew that it was a good tool I simply needed to sharpen it a bit.

## Simplifying the keyboard shortcuts

Vim thought me two important lessons: to always keep my fingers on the home row,
and to make my commands easy to remember. I wanted to replicate this behaviour
in my Tmux setup as well.

First, I stopped using the slow `Ctrl b` or `Ctrl a` prefix for my Tmux
commands. Instead, I reused a key on my keyboard that I never used &mdash; the
Alt key.

Second, I wanted my `s` key to represent a `split`, the `w` key to represent a
window, and the `hjkl` keys to represent movement. That is how I created the
following shortcuts:

Creation:

- `Alt + s` - Create a new horizontal split
- `Alt + S` - Create a new vertical split
- `Alt + w` - Create a new window

Split Movement:

- `Alt + h` - Move to split on the left
- `Alt + j` - Move to split bellow
- `Alt + k` - Move to split above
- `Alt + l` - Move to split on the right

Window Movement:

- `Alt + H` - Move to previous window
- `Alt + L` - Move to next window

Changing split dimensions:

- `Alt + <` - Resize the split to the left
- `Alt + >` - Resize the split to the right

## Moving the tmux panel to the top

I always prefer to use two, and exactly two, monitors. One where my terminal is
in full screen, and one where my browser is in full screen. My browser keeps its
tabs on top. It makes a whole lot of sense to keep my tmux tabs(windows) on the
top as well.

It reduced the time necessary to move and adjust my eyes between two screens.
Simple change, but it means a lot.

## Making simple things simple

You might be wondering, why did I wrote a whole article about such a simple
topic. Let me share a story.

When I was younger, I craved for the big and complex. If something was more more
complex, it was automatically a better thing in my eyes. However, with time and
experience, I learned to love and adore the simple and the mundane.

Keeping simple things simple, and transforming complexity into simplicity, is
the main goal of my every programming endeavor. Take a look how I achieved
simplicity with my
[Tmux configuration](https://github.com/shiroyasha/dotfiles/blob/master/files/tmux.conf).

Let's keep Tmux simple and fast.
