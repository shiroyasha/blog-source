---
title: Shebang
date: 2014-12-01
tags: shell
image: shebang.png
---

Unix systems are really smart when it comes to interpreting your application. Not only do  they provide you with an excellent environment for development, but also let you specify the interpret in you source file. As it turns out, this technique lets you write an application in any programming language without forcing your end users to know the details of your implementation. This article is about describing this simple technique.

Lets start with an example hello world application written in bash script.

``` bash
echo "Hello world!"
```

To execute such a program we must do two things. Make the program executable, and run it with the bash interpreter.

``` bash
$ chmod +x hello_world.sh
$ bash hello_world.sh
Hello world!
```

Now, we can add the shebang to the start of the program.

``` bash
#!/bin/bash
echo "Hello world!"
```

and with that simple addition we can now invoke our program without the bash interpreter

```bash
$ ./hello_world.sh
```

## Rules for the shebang

The shebang command must be the first line of the file and can contain any valid path for the interpreter, followed by the arguments that will be sent with the invocation.

The shebang line is read by the system before the execution of the program, but the shebang line will not be automatically deleted. So if you want to write your own interpreter, you must manually handle that line.

For example we can even write a program that outputs itself by writing

``` sh
#!/bin/cat
Answer to the ultimate question is 42!
```

## Summary

This is one of the easiest things you can learn to write better scripts,  and it is invaluable if you never heard of it before.

Happy hacking!
