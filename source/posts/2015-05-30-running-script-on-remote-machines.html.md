---
id: 55ce2ff3-d661-4805-acaf-fca5cac327ab
title: Running scripts on remote machines
tags: shell, bash
image: running.png
---

Several days ago a colleague and I wanted to check whether our caching system
contains all the files that we expect it to contain. We started by writing a
bash command that would list and compare the available files. It had
the following structure:

``` sh
cd somewhere && untar archive && diff <(ls -lah directory) <(ls -lah other_directory)
```

We run the above command through an ssh connection from our local machine.
In other words we did something along these lines:

``` sh
ssh cacher@cache-server "cd somewhere && untar archive && diff <(ls -lah directory) <(ls -lah other_directory)"
```

As you can see the above command is pretty long even in this form. But it wasn't 
sufficient. We added a couple of `sed`, `grep`, `awk`, `tail`, `while` commands just to make
the output more human friendly. The result was a 4 lines long beast command that we
tried to keep in a one long readline session. Imagine something like this:


``` sh
ssh cacher@cache-server "cd somewhere && untar archive && ls directory | while read directory; do && diff echo $directory; <(ls -lah directory | grep "*.*\1" | sed "s/\.spec//g" | tail) <(ls -lah other_directory | grep "*.*\1" | sed "s/\.spec//g" | tail) && echo "No errors" || echo "Error!!!"; done"
```

To make the command even more horrible, we run it on several remote machines with a nifty
`for` loop:

``` sh
for server in "${servers[@]}"; { ssh cacher@$server "cd somewhere && untar archive && ls directory | while read directory; do && diff echo $directory; <(ls -lah directory | grep "*.*\1" | sed "s/\.spec//g" | tail) <(ls -lah other_directory | grep "*.*\1" | sed "s/\.spec//g" | tail) && echo "No errors" || echo "Error!!!"; done" }
```

Hunting down syntax errors was tedious, every time moving around with the left
and right arrow... It was the time to put the command into a shell script!

## The script

When you put the above command in a shell script, it becomes nice and tidy: 

``` sh
cd somewhere
untar archive

ls directory | while read directory; do
  echo $directory;

  original_list=$(ls -lah $directory | grep "*.*\1" | sed "s/\.spec//g" | tail)

  new_list=$(ls -lah other_directory | grep "*.*\1" | sed "s/\.spec//g" | tail)
  
  if diff <(echo original_list) <(echo new_list); then
    echo "No errors"
  else
    echo "Error!!!";
  fi
done
```

But, how can we run the script on a remote machine?

The srtaight forward solution is to `scp` it to the remote machine and then execute
the script with an `ssh` commmand:

``` sh
for server in "${servers[@]}"; { scp script.sh $server:/tmp/script.sh && ssh cacher@$server "bash /tmp/script.sh && rm /tmp/script.sh"}
```

But, this still looks horible... Let's look at an alternative...

Turns out you can push a file into the ssh command and ssh will redirect it to a
remote command:

``` sh
ssh cacher@cache-server "bash -s" < script.sh
```

With this we remove the need for a temp file, and the above command becomes:

``` sh
for s in "${servers[@]}"; { ssh cacher@$s "bash -s" < script.sh }
```

This form looks acceptable.



















