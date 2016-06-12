---
title: The importance of a good command line shell prompt
date: 2016-06-12
tags: programming
image: running-shell-commands-from-ruby.png
---

A lot of developers choose to avoid the often big, clumsy and complicated
IDEs in favor of the Linux command line. At first sight the command line
is inferior to the experience you get from a full blown IDE. However, the
beauty of the command line is just that. It is fast, simple, and by default
it comes with very small set of pre-installed features.

To make the best use of the command line, you will have to invest your time to
learn and configure the various parts of the system. At first, this time
investment will slow you down, but with time, your investment will reward you
development workflow exponentially.

One of the first things you want to modify in your shell is command line prompt.

## The prompt

In case you are unfamiliar with the term _prompt_, it is the text that appears
every time you want to enter a new command in your shell.

![Default Linux prompt](images/prompt/default-prompt.png)

In the above image we consider `vagrant@local:/tmp$` to be our prompt. On Ubuntu
it displays several nifty information useful for our everyday tasks. For
example, in the above image you can immediately recognize the following:

- current Linux user (in this case _vagrant_)
- the hostname of the machine (in this case _local_)
- the current directory (in this case _tmp_)
- the authority level (`$` for normal users, `#` for admins)

These are very valuable information when you enter the system for the first
time, or when you SSH into an unfamiliar remote server. However, for a local
development environment, it contains too much information that we don't really
care about (hostname and username for example).

This is very the power of the shell comes handy. If we don't like something,
there is usually a really simple, _scriptable_, way to change it. In the case of
the prompt, we want to modify the `PS1` environment variable. For exercise sake,
we will remove the username and the hostname from our `PS1` variable.

But first, let's peek at the current value:

``` bash
vagrant@local:/tmp$ echo $PS1
${debian_chroot:+($debian_chroot)}\u@\h:\w\$
```

The `\u` represents the current user, and `\h` the current hostname. Let's
remove everything except the `\w` that represents the current directory.

``` bash
vagrant@local:/tmp$ export PS1='\w\$'
```

Your shell should have changed immediately. If you have done everything right,
you should see the following:

``` bash
/tmp$
```

However, this change will not last long. More specifically, it will stay
unchanged until the next time you log into your system. To make this change
permanent, we should execute it every time when you log into your system.

On Linux, or more specifically bash, if you want to execute something every time
you log into the system, you should put it inside the `~/.bashrc` file.

Let's do that. Open the file, and add `export PS1='\w\$'` as the last line. Now,
your change in the prompt will remain permanent.

## Ideas for an awesome command line prompt

The above was just a quick introduction. You can, and if care about yourself
then you must, change and tweak your prompt even further. Here are some ideas I
use to boost my shell productivity.

### Exit status indicators

It has been a long time since we moved from monochromatic displays to the ones
that support colors. We should definitely make use of this fact. However,
instead of making our simply colorful, we can use the colors to attach meaning
to some events and make an awesome indicator in our prompt.

The green and red colors are a very good indicators for representing the success
of the previous command. If the previous command returned an exit status `0` we
can color our prompt indicator green, and red otherwise.

![Exit status prompt indicator](images/prompt/exit_status.png)





























