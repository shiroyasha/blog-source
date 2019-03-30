---
id: cb486a8e-0b82-4f88-beee-637365370b76
title: Strive for Software Autonomy, not just Process Automation
date: 2019-03-30
tags: programming
image: 2019-03-30-strive-for-software-autonomy-not-just-process-automation.png
---

We made some major steps in software automation, more specifically release
automation. We coined the word DevOps and invented a culture that unites
developers and operations. We invented the term infrastructure as code that
represents our ability to store the state of our systems in textual documents, 
and on-demand reproduce that state. Our systems become immutable, revertable,
observable.

The common factor shared in all the previous advancements is the reduction of
operators necessary to complete a task. With greater automation, operations that
once demanded a week of well-coordinated effort team effort can now be completed
in a matter of minutes by a single person. This gave us a free room to invent
and to solve real issues, and not be bogged down by meaningless toil.

The next step in this evolution is to completely remove the necessity for
unnecessary toil. The next step is to strive for software that can live on its
own. Software that can be autonomous.

There's a subtle yet very important difference between the semantic meaning of
the words automatic and autonomous. The first one, automatic, is what our
collective vocabulary is focused on right now. We recognize the steps we need to
take manually, codify them, and in this process make them automatic. The process
itself hasn't changed. It still has the same perspective, it is only faster, and
more reliable. The second word, autonomous, implies that our software can make
decisions on its own. Software that can react and adjust to a desirable state.
This activity still requires automation in its core, but the focus has shifted.
The question is no longer how I can make this process faster, or more reliable,
the new question is how I can make this software independent.

Like any other cultural shift in our industry, to reach the state of software
autonomy, we first need to adjust our vocabulary.

# Codify Goals instead of Tasks

A good example of aiming for software autonomy is how you approach routine
maintenance tasks in your system. You can either codify and automate the steps
you usually take to process a maintenance task, or you can codify the goals you
want to achieve when the task is finished.

A concrete example would be installing a new node in your infrastructure.

Your end goal can be to set up a Chef/Puppet/Ansible cookbook that codifies the
steps necessary to spin up this machine. This would satisfy the automation part.

Or you can aim higher and ask a fundamental question. Why do I want to have new
nodes in my system? Do I want to make sure that I have enough servers to handle
the incoming request load? I should, in that case, codify this goal instead.
Keep in mind that this is not just an incremental upgrade compared to the
Chef/Puppet/Ansible approach. This new system needs to monitor and react to some
meaningful numbers in the system and take a series of steps to satisfy that
goal. For this task, our classical automation tools might just not cut it. 

# Don't just observe the system, let the system react to problems

Any good production ready system should come with a set of metrics that
communicates its health to the operators. Prometheus, InfluxDB, Grafana, StatsD,
and Fluentd have made some major advances. These systems, however great, are
still not the ultimate end. They assume that there is an operator that keeps an
eye on the system, makes judgment calls, and reacts to issues. In this system,
an operator is part of the system. A human operator that wants to sleep during
the night.

Is your software a toddler that needs 24h human monitoring? Can it stand up when
it falls down? Can it self-correct when it makes a mistake? Be courageous enough
to let it act on its own. Let it try to fall, and stand up. Let your system
evolve to live on its own, instead of hanging on to your hands.

A concrete example of this is releasing new versions of your software. You can
focus on automating deployment, automating rollbacks, and patiently observing
the metrics of the new release. Or you can set up a system where you offer a new
version, and the system decides if it wants to keep running it. Automated
Blue/Green deployment is a good step in this direction. A new blue version is
offered up. The system monitors itself for a given amount of time. If everything
is right the system evolves to a new green state. There is no human that needs
to trigger a rollback if something goes wrong.

# Talk about your system as a part of your team

Your system should not be something that you maintain. Your system should evolve
and start making decisions on its own. This should be reflected in your everyday
vocabulary as well.

For example, instead of saying we will add a new node, we should aim for we will
tell the system to improve its response rate.

If you change your vocabulary and start talking about your system as a part of
your team, you will make sure that everyone in your team understands that your
system should be an autonomous entity. This will shift your collective
perspective from automating tasks, to teaching your software to do those tasks
instead of you.
