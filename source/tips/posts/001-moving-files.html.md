---
title: Moving files with curly braces
date: 2015-05-26
tags: shell, bash
image: moving_files.png
---

Did you ever had to rename a part of a relly long filename?

``` sh
mv really-fake-and-really-long-file-name.html not-fake-and-really-long-file-name.html
```

Or rename files several directories bellow your path?

``` sh
mv tips/source/posts/latest/images/dog.html tips/source/posts/latest/images/cat.html
```

Using some curly braces can help to ease up the pain:

``` sh
mv {really,not}-fake-and-really-long-file-name.html
```

``` sh
mv tips/source/posts/latest/images/{dog,cat}.html
```

It can even help you to add a suffix to your commands, and instead of 
creating backups with:

``` sh
mv .vimrc .vimrc.backup
```

You can simply write:

``` sh
mv .vimrc{,.backup}
```

and the following to reuse the backup:

``` sh
mv .vimrc{.backup,}
```

It seems like a trivial thing, but if you spend as much time in the terminal
as I do, you will start to value these simple tips and tricks that can make
you job at least a little bit faster.

To learn more about this tehnique called Brace Expansion visit the 
[bash docs](http://www.gnu.org/software/bash/manual/html_node/Brace-Expansion.html).
