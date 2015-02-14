---
title: Running shell commands from Ruby
date: 2015-02-06
tags: shell
image: running-shell-commands-from-ruby.png
---

Ruby is an excellent language offering us a simple and human friendly
interface, however for system administration or simple task automation the
shell is a much better alternative. Luckily, combining them is easy. 

There are many ways to interact with the shell (back-ticks, system, exec,
open3, ...), but I am not going to list and explain every one of them (go read
the docs or [this thread](http://stackoverflow.com/a/2400/364938)) and instead
I will focus on the interaction of the two languages.

Let's start with a simple example and list the content of the directory. In
ruby we will use the back-ticks syntax to _capture the output_ of the `ls`
command:

``` ruby
output = `ls`

puts output
```

OK, that was easy. In this next example let's execute a shell action that will
install [Vim](http://www.vim.org/) on a [Ubuntu](http://www.ubuntu.com/)
machine. We will use the `system` command instead of the back-ticks, so we can
_join the output_ of the command with the output of our ruby script.

``` ruby
system "sudo apt-get -y install vim"
```

This should work fine. But not always...  If your internet connection is
broken, or if the vim package changes its name, the above command will fail
without our Ruby script knowing anything about it.

Hopefully, there is an easy solution. The `$?` global variable always contains
the status code of the last executed shell command. Let's use to show an error
message to the user:

``` ruby
system "sudo apt-get -y install vim"

if $?.exitstatus > 0
  puts "I failed to install Vim, I am very sorry :'(" 
end
```

With the above knowledge you can do *a lot*. But sooner or later you will
stumble on one little detail &mdash; the system and the back-ticks execute 
`sh` commands, and *not* Bash commands. And there are a 
[lot of differences](http://www.gnu.org/software/bash/manual/html_node/Major-Differences-From-The-Bourne-Shell.html)
between the two of them.

For example in Bash you have [process
substitution](http://en.wikipedia.org/wiki/Process_substitution) that is very
handy, yet not available in Sh. Let's write a Ruby script that uses it.

A good use case for process substitution is to check if two directories have
the same files in them. In the command line we would write such a test like
this:

``` bash
cmp <( ls ~/images ) <( ls ~/images-backup )
```

Following the above example, a naive Ruby implementation would be:

``` sh
system "cmp <( ls ~/images ) <( ls ~/images-backup )"

if $?.exitstatus == 0
  puts "They are the same, yay!"
else
  puts "They are not the same"
end
```

But this will fail with a weird error that looks similar to this:

``` sh
sh: 1: Syntax error: "(" unexpected
```

Hopefully, the system command can take multiple arguments and will threat the
first one as the command and the rest as its arguments. For example we can list
the `/etc` directory with:

``` sh
system "ls", "/etc"
```

If you are familiar with the command line you probably know that you can run
commands in an alternative shell with:

``` sh
bash -c "echo 'running from bash shell!'"
```

Now let's use the above knowledge to compare two directories from a Ruby
script:

``` sh
system "bash", "-c", "cmp <( ls ~/images ) <( ls ~/images-backup )"

if $?.exitstatus == 0
  puts "They are the same, yay!"
else
  puts "They are not the same"
end
```

Hooray, this works!

I hope I have given you the incentive to go and explore this technology even
further. Happy hacking!
