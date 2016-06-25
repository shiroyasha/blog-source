---
title: Comparing files on different servers
tags: shell, bash
image: comparing-files.png
---

Let's say you have two servers named `gandalf` and `charmander`, and a configuration
file `config.xml` that should be present on each server. Due to some human error
the files got different and your servers started to act weird. It would be nice
to compare them and find out what part of them is different.

Luckily, you have `ssh` access to both servers. A simple solution is to `scp` both
file to a local temp file and compare them with `diff`.

``` sh
scp gandalf:~/config.xml /tmp/gandalf_config.xml
scp charmander:~/config.xml /tmp/charmander_config.xml

diff /tmp/gandalf_config.xml /tmp/charmander_config.xml
```

The above works like a charm, but can we do it in fewer steps? Well, if the files are
not gigantic we can use the `<( command )` pattern to compare them without temp files.

``` sh
diff <(ssh gandalf "cat ~/config.xml") <(ssh charmander "cat ~/config.xml")
```

This technique is called [Process substitution](http://tldp.org/LDP/abs/html/process-sub.html)
and can have even more powerful use cases.

## Scaling the issue

But what if we have more than two servers, lets say a hundred, and we want to check whether
we have the same configuration file on every one of them?

A good server naming scheme combined with a `for` loop can help us a lot. A good naming
scheme can be to replace special names like `gandalf` and `charizard` with a baring yet
wastly more handy form like the following: 

```
s1, s2, ... s100
```

First, let's save a local copy of a good configuration file:

``` sh
scp s1:~/config.xml /tmp/good
```

To compare this file with a remote file we can use the above scheme:

``` sh
diff /tmp/good <(ssh s2 "cat ~/config.xml")
```

and loop through all the servers with a nifty `for` loop:

``` sh
for i in {2..100}; { diff /tmp/good <(ssh "s$i" "cat ~/config.xml") }
```
