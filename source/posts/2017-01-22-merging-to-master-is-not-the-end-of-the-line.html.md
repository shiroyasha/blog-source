---
id: 7da14a7b-662e-41d4-9526-5249157c91e0
title: Merging to Master is not the end of the line
date: 2017-01-22
tags: programming
image: merging-to-master-is-not-the-end-of-the-line.png
---

After weeks of planing, painful debugging sessions, and making sure that
everything is covered with tests, your feature branch turns green. You are
ready to merge into master and deploy to production. You hit the "Merge" button
on GitHub, open your CI service and watch how master turns green.
Automatically, deployment to production is triggered, and after several minutes
your new feature goes live.

READMORE

Woohoo! You have done a great job. Time to open your a bottle of the finest
whiskey in the office and celebrate with your team. You are now ready to tackle
new challenges!

Not so fast! Writing good code and deploying to production is not the end of
the game, you have only done half of the job. Think about it. What is your job?
To write good code that produces zero bugs, or to make a useful new feature that
will improve the lives of your users? Hopefully, you choose the second answer.

If you share my beliefs, a good programmer should always aim to make someone's
life better. You must make sure, to not only write good code, but to make
that code easily and instantly usable. In rare occasions, it is even better to
simply remove the new feature if you have not met your users expectation.

So, what should I do after deployment? Test, measure, communicate and
celebrate with your team!

## Test running your new feature

You can go two ways with releasing a new feature. You can simply push to
production and make the new feature available instantly to all users,
or you can hide your new feature behind a feature flag.

I always prefer to use a feature flag. This allows me to deploy features
that are not yet polished. Instead of wasting time and trying to find every edge
case &mdash; a process which can take days or even weeks &mdash; I can push
immediately and verify that the new feature delivers its basic promises.

With this in mind, my first step after pushing to production is to enable the
feature for my team and to give it a test run. If I am happy with the results
I continue the testing by visiting every team in my office to enable them
the new feature. During this process, I gather valuable feedback and record
every bug that we encounter.

A very good practice is to include existing users into the test phase.
A simple email that explains the awesomeness of our new feature can go a
long way. From one side, it reassures our customers that we truly care about
their needs and that we highly value their feedback. From the other side we
can get an outsider's opinion, someone's opinion who is not familiar with our
code base and is not blinded with the technical limitations of our
infrastructure.

## Setting up metrics and alerts

Every test went well, and you and your team are convinced that the new feature
has a true potential. Now it is time to set up some metrics.

First, you must make sure that the basic metrics are set up. The ones that
measure overall response time, performance of the most critical method calls,
and metrics for the affected records in your database.

This is the step, where you want to make sure that your feature works not only
for you and your team, but it works correctly for thousands or millions of
users. I always like to say to myself: "If a user has a painful experience
using my software, I should feel at least double the amount of that pain".

PagerDuty is the worst, especially when it calls during the night, but it is
also the best incentive to make my software truly stable and bug free. Also, it
is far better to be awaken during the night, than to wake up in the morning and
handle thousands of customer complaints.

When the basic metrics and alerts are covered and tested, it is time to
implement a truly valuable metric &mdash; a metric that can track the happiness
of our users. This is usually much harder to measure, but you should at least
make sure that you have covered the simplest things: how many clicks does
it take to use the new feature, how long does it take to set it up, and what is
the ratio of users who have tried, succeeded, or dropped of in the process.

## Announcing the new feature

You should now be fairly confident that your new feature is good enough to be
used by real people. It is time to let the world know.

First, I like to make sure that I have notified everyone in the company that
a new feature is coming. That includes customer support who will suffer the most
if I failed to make the software bulletproof, marketing folks who are far
more capable in bringing the new feature closer to my audience, and of course
the rest of the programming crew who might suffer if something breaks
the infrastructure.

Then, it is time to prepare a public announcement. I always like to start with
a simple blog post. Nothing too fancy, simply a "Hey guys, we produced something
new. Give it a try." post with several screenshots.  You don't need to be a
marketing/seo guru to do this, but you do need to take this step as serious as
the coding part.

When everything is ready, I click the "enable" button for my new feature,
publish the blog post, and write a short summary on Twitter.

My new feature is now live.

## Communicating with the users

Is everything ready now, can I start celebrating? Not so fast. Your new feature
has just be announced, how can you be sure that it is successful?

Tracking the behaviour of early adopters is a must. We must make sure that they
are happy with the change. Unfortunately, many of them won't be happy, people
don't like change, even if it a change for the better. Now, our primary task is
to collect the feedback, improve, and to collect even more feedback.

It is also totally acceptable to contact the early adopters, and ask for
feedback. Engineers are usually very afraid of this part, but we really
shouldn't be. This experience can be very rewarding and an excellent way connect
our feeling with the feelings of our users.

Being open and friendly is always the best way to go.

## Opening the bottle of the finest whisky

Everything went great, and some folks are sending us "This rocks guys, keep
up the good work!"? If yes, then the time has come to open a bottle of the
finest booze.

Never skip this step. It is very important to celebrate every victory. It brings
the team closer and it gives us the stamina to do this once again.

Lets keep shipping great software! Cheers!
