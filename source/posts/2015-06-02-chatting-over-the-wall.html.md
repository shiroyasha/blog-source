---
id: 00bb9753-4b57-4dc2-9fb1-49ca0a784614
title: Chatting over the Wall
tags: shell, bash
image: wall.png
---

This is how usually all our geeky adventures start out: A colleague walks up to my desk 
and says: "I must show you something interesting!!!". Last Friday this cool thing was 
the `wall` command.

You have probably never used it directly, but if you are a Linux geek like we are, you have probably
seen it countless times in action. The `poweroff` command uses it to display a system wide
notification for all the users.

Here is our first experiment with it:

``` sh
echo "System is shutting down!" | wall

Broadcast Message from igor@gandalf
(/dev/pts/10) at 21:58 ...         

System is shutting down!           
```

The above message is sent to all the users who are currently logged in
via an ssh connection.

Our next use case was to find some unsuspecting colleagues who are working on a staging
server, and frighten them with a message like:

``` sh
echo "CPU temperature is above the melting point" | wall
```

It was unbelievably fun :D

After several "Stop messing with me!" looks, we tried to implement something different &mdash; 
a poor man's chat server.
Everybody would log into a remote server via an SSH connection, and we would communicate
with each other by broadcasting messages over the `wall`.

I would write:

``` sh
echo "Hi!" | wall

Broadcast Message from igor@gandalf  
(/dev/pts/10) at 21:59 ...         

Hi!                                
```

Someone else would reply with:

``` sh
echo "Stop slacking, get back to work!" | wall

Broadcast Message from shiroyasha@gandalf 
(/dev/pts/10) at 21:59 ...                

Stop slacking, get back to work!          
```

Good times... :'D

After these little play sessions we figured out that this nifty little command can help
us achieve even something useful. It is the perfect tool to let everyone know that you
doing something potentially dangerous in a case of an emergency, or that you are 
doing something that could disturb the experiments that other people are executing on
this same server.
