---
id: 6cbdee79-6dcf-4409-9486-b696c6be6bf3
title: Killing a process and all of its descendants
date: 2019-08-02
tags: programming
image: 2019-08-02-killing-a-process-and-all-of-its-descendants.png
---

Killing processes in a Unix-like system can be trickier than expected. Last
week I was debugging an odd issue related to job stopping on Semaphore.
More specifically, an issue related to the killing of a running process in a
job. READMORE

Here are the highlights of what I learned:

- Unix-like operating systems have sophisticated process relationships.
- Sending signals to all processes in a session is not trivial with syscalls.
- Processes started with exec inherit their parent signal configuration.
- There are many challenges with handling orphaned process groups.

There are multiple types of relationships between processes. Parent-child,
process groups, sessions, and session leaders. However, the details are not
uniform across operating systems like Linux and macOS. POSIX compliant
operating systems support sending signals to process groups with a negative
PID number.

## Killing a parent doesn't kill the child processes

Every process has a parent. We can observe this with `pstree` or the `ps` utility.

``` shell
# start two dummy processes
$ sleep 100 &
$ sleep 101 &

$ pstree -p
init(1)-+
        |-bash(29051)-+-pstree(29251)
                      |-sleep(28919)
                      `-sleep(28964)

$ ps j -A
 PPID   PID  PGID   SID TTY      TPGID STAT   UID   TIME COMMAND
    0     1     1     1 ?           -1 Ss       0   0:03 /sbin/init
29051  1470  1470 29051 pts/2     2386 SN    1000   0:00 sleep 100
29051  1538  1538 29051 pts/2     2386 SN    1000   0:00 sleep 101
29051  2386  2386 29051 pts/2     2386 R+    1000   0:00 ps j -A
    1 29051 29051 29051 pts/2     2386 Ss    1000   0:00 -bash
```

The `ps` command displays the PID (id of the process), and the PPID (parent ID
of the process).

I held a very incorrect assumption about this relationship. I thought that if I
kill the parent of a process, it kills the children of that process too.
However, this is incorrect. Instead, child processes become orphaned, and the
init process re-parents them.

Let's see the re-parenting in action by killing the bash process — the current
parent of the sleep commands — and observe the changes.

``` bash
$ kill 29051 # killing the bash process

$ pstree -A
init(1)-+
        |-sleep(28919)
        `-sleep(28965)
```

The re-parenting behavior was odd to me. For example, when I SSH into a server,
start a process, and exit, the started process is killed. I wrongly assumed this
is the default behavior on Linux. It turns that killing of processes when I
leave an SSH session is related to process groups, session leaders, and
controlling terminals.

## What are process groups and session leaders?

Let's observe the output of `ps j` from the previous example again.

``` bash
$ ps j -A
 PPID   PID  PGID   SID TTY      TPGID STAT   UID   TIME COMMAND
    0     1     1     1 ?           -1 Ss       0   0:03 /sbin/init
29051  1470  1470 29051 pts/2     2386 SN    1000   0:00 sleep 100
29051  1538  1538 29051 pts/2     2386 SN    1000   0:00 sleep 101
29051  2386  2386 29051 pts/2     2386 R+    1000   0:00 ps j -A
    1 29051 29051 29051 pts/2     2386 Ss    1000   0:00 -bash
```

Apart from the parent-child relationship expressed by PPID and PID, we have two
other relationships:

- Process groups represented by PGID
- Sessions represented by SID

Process groups are observable in shells that support job control, like `bash`
and `zsh`, that are creating a process group for every pipeline of commands. A
process group is a collection of one or more processes (usually associated with
the same job) that can receive signals from the same terminal. Each process
group has a unique process group ID.

``` bash
# start a process group that consists of tail and grep
$ tail -f /var/log/syslog | grep "CRON" &

$ ps j
 PPID   PID  PGID   SID TTY      TPGID STAT   UID   TIME COMMAND
29051 19701 19701 29051 pts/2    19784 SN    1000   0:00 tail -f /var/log/syslog
29051 19702 19701 29051 pts/2    19784 SN    1000   0:00 grep CRON
29051 19784 19784 29051 pts/2    19784 R+    1000   0:00 ps j
29050 29051 29051 29051 pts/2    19784 Ss    1000   0:00 -bash
```

Notice that the PGID of `tail` and `grep` is the same in the previous snippet.

A session is a collection of process groups, usually associated with one
controlling terminals and a session leader process. If a session has a
controlling terminal, it has a single foreground process group, and all other
process groups in the session are background process groups.

![sessions](images/killing-a-process-and-all-of-its-descendants/sessions.png)

Not all bash processes are sessions, but when you SSH into a remote server, you
usually get a session. When bash runs as a session leader, it propagates the
SIGHUP signal to its children. SIGHUP propagation to children was the core
reason for my long-held belief that children are dying along with the parents.

## Sessions are not consistent across Unix implementations

In the previous examples, you can notice the occurrence of SID, the session ID
of the process. It is the ID shared by all processes in a session.

However, you need to keep in mind that this is not true across all Unix
implementations. The Single UNIX Specification talks only about a "session
leader"; there is no "session ID" similar to a process ID or a process group ID.
A session leader is a single process that has a unique process ID, so we could
talk about a session ID that is the process ID of the session leader.

System V Release 4 introduced Session IDs.

In practice, this means that you get session ID in the `ps` output on Linux, but
on BSD and its variants like MacOS, the session ID isn't present or always zero.

## Killing all processes in a process group or session

We can use that PGID to send a signal to the whole group with the kill utility:

``` bash
$ kill -SIGTERM -- -19701
```

We used a negative number `-19701` to send a signal to the group. If kill
receives a positive number, it kills the process with that ID. If we pass a
negative number, it kills the process group with that PGID.

The negative number comes from the system call definition directly.

Killing all processes in a session is quite different. As explained in the
previous section, some systems don't have a notion of a session ID. Even the
ones that have session IDs, like Linux, don't have a system call to kill all
processes in a session. You need to walk the `/proc` tree, collect the SIDs, and
terminate the processes.

Pgrep implements the algorithm for walking, collecting, and process killing by
session ID.  Use the following snipped:

``` bash
pkill -s <SID>
```
Nohup propagation to process descendants

Ignored signals, like the ones ignored with `nohup`, are propagated to all
descendants of a process. This propagation was the final bottleneck in my bug
hunting exercise last week.

In my program — an agent for running bash commands — I verified that I have an
established a bash session that has a controlling terminal. It is the session
leader of the processes started in that bash session. My process tree looks like
this:

``` bash
agent -+
       +- bash (session leader) -+
                                 | - process1
                                 | - process2
```

I assumed that when I kill the bash session with SIGHUP, it kills the children
as well. Integration tests on the agent also verified this.

However, what I missed was that the agent is started with `nohup`. When you
start a subprocess with `exec`, like we start the bash process in the agent, it
inherits the signals states from its parents.

This last one took me by surprise.
