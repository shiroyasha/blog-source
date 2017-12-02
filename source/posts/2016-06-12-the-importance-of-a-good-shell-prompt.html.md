---
id: a4f2ff6f-76b4-42b6-9580-3fd0bb0abf04
title: The importance of a good command line prompt
tags: programming
image: running-shell-commands-from-ruby.png
---

A lot of developers choose to avoid the often big, clumsy and complicated
IDEs in favor of the Linux command line. At first sight the command line
is inferior to the experience you get from a full blown IDE. However, the
beauty of the command line is just that. It is fast, simple, and by default
it comes with very small set of pre-installed features.

READMORE

To make the best use of the command line, you will have to invest your time to
learn and configure the various parts of the system. At first, this time
investment will slow you down, but with time, your investment will reward you
development workflow exponentially.

One of the first things you want to modify in your shell is the command line prompt.

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

These are valuable information when you enter the system for the first
time, or when you SSH into an unfamiliar remote server. However, for a local
development environment, it contains too much information that we don't really
care about (hostname and username for example).

This is where the power of the shell comes handy. If we don't like something,
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

Let's do that. Open the file, and add `export PS1='\w\$'` at the end of the
file. Now, your change in the prompt will remain permanent.

## Ideas for an awesome command line prompt

The above was just a quick introduction. You can, and if care about yourself
then you must, change and tweak your prompt even further. Here are some ideas I
use to boost my shell productivity.

### Exit status indicators

It has been a long time since we moved from monochromatic displays to the ones
that support colors. We should definitely make use of this fact. However,
instead of making our prompt just colorful, we can use the colors to attach
meaning to some events and make an awesome indicator in our prompt.

The green and red colors are a very good indicators for representing the success
of the previous command. If the previous command returned an exit status `0` we
can color our prompt indicator green, and red otherwise.

![Exit status prompt indicator](images/prompt/exit_status.png)

### Current directory display

I am not a big fan of long command line prompts. A good way to save some place
on your command prompt is to display only the name of the current directory
instead of the full path.

For example, instead of the following:

``` bash
code/blog/source/images/prompt $
```

I am perfectly fine with displaying only:

``` bash
prompt $
```

At first, you may find the lack of the full path confusing, but with time you
get used to it and you rarely need to lookup the full path.


### Git branch

As a developer, you probably spend most of your time in git repositories. A
valuable information on your prompt can be the name of the current branch. This
comes even more handy when you have dozens of repositories on your machine.

For example, I store all of my repositories in the `~/code` directory. When I
enter a directory, I want to have a way to immediately recognize the state where
I left off work yesterday.

![Git branch in the prompt](images/prompt/git-branch.png)

### Git status indicators

Another useful information in the prompt can be the state of your git
repository. Instead of writing `git status` every time you want to check if you
have some uncommitted changes, you can use the combination of the green/red
color to get this information effortlessly.

In my prompt, if the name of the branch is green, that means that I don't have
any uncommitted changes. It is red otherwise.

![Git status in the prompt](images/prompt/git-status.png)

### Minimized jobs

If you are anything like me, you probably open a lot of files with Vim, edit
them, minimize them with `Ctrl+z`, commit the changes, and then continue to edit
the file by doing `fg`.

Unfortunately, I used to forget that I have minimized some of the Vim windows,
and I ended up with several open files, that sometimes conflicted with each
other.

To avoid this pain, I decided to display this information on my prompt. I use
the following logic: If I have zero minimized jobs, the prompt displays nothing.
If I have one or more jobs, the prompt displays the count of the jobs.

![Job count on the prompt](images/prompt/job-count.png)

## Final words

If you like the above changes, you can take a peek at my [current zsh
prompt](https://github.com/shiroyasha/dotfiles/blob/master/files/prompt).

Also, a good source of inspiration can be the awesome [oh-my-zsh
project](https://github.com/robbyrussell/oh-my-zsh) or the [bash-it
project](https://github.com/Bash-it/bash-it) if you prefer Bash as your shell.

Hope you enjoyed the article.<br>
Stay awesome!
