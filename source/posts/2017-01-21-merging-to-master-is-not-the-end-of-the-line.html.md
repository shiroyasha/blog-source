---
id: 7da14a7b-662e-41d4-9526-5249157c91e0
title: Merging to Master is not the end of the line
date: 2017-01-21
tags: programming
image: 2017-01-21-merging-to-master-is-not-the-end-of-the-line.png
---

After weeks of planing, painful debugging sessions, and making sure that
everything is covered with tests, your feature branch turns green and you are
ready to merge into master and deploy to production. You hit the "Merge" button
on GitHub, open your CI service and watch how master turns green.
Automatically, deployment to production is triggered, and after several minutes
your new feature goes live.

Woohoo! You have done a great job. Time to open your a bottle of the finest
whiskey in the office and celebrate with your team. You are now ready to tackle
new challenges! Not so fast! Writing good code and deploying to production is
not the end of the game, you have only done half of the job.

Think about it. What is your job? To write good code that produces zero bugs, or
to make a useful new feature that will improve the lives of your users?
Hopefully, you choose the second answer.

If you share my beliefs, a good programmer should always aim to make someone's
life better. You must make sure that you not only write good code, but to make
that code easily and instantly usable. In rare occasions, it is even better to
simply remove the new feature if you have not met your users expectation.

## Test running your new feature

You can go two ways with releasing a new feature. You can simply push to
production and make the new feature available for all users, or you can hide
your new feature behind a feature flag.

I almost always prefer to use a feature flag. It helps me to release new
features much faster, because at first it is only enabled for my team only. This
allows me to deploy features that are not yet polished. Instead of worrying, and
trying to find every edge case &mdash; a process which can take days or even
weeks &mdash; I can push immediately and verify that the new feature delivers
its basic promises.

With this in mind, my first step after pushing to production is to enable the
feature for my user, and giving it a test run. If I am happy with the results,
the next step is to enable the feature for my team, and then if everything goes
smoothly I go from team to team and enable the new feature, gathering valuable
feedback and recording every bug that we encounter.

A very good practice can also be to include existing customers into the test
phase. A simple email that explains the awesomeness of your new feature can go a
long way. From one side, it reassures your customers that you truly care about
their needs and that you highly value their feedback. From the other side you
can get an outsiders opinion, someone who is not familiar with your code base
and is not blinded with the technical limitations of your software.

## Setting up metrics and alerts

Every test went well, and you and your team are convinced that the new feature
has a true potential. Now it is time to set up some metrics.

First, you must make sure that the basic metrics are in its place. The ones that
measure overall response time, performance of the most critical method calls,
and metrics for the affected records in your database.

This is the step, where you want to make sure that your feature works not only
for you and your team, but it works correctly for thousands or millions of
customers.

I always like to say to myself: "If a user has a painful experience using my
software, I should feel double the amount of that pain". PagerDuty is the worst,
especially when it calls during the night, but it is the best incentive to make
my software truly stable and bug free. Also, it is far better to be awaken
during the night then to wake up in the morning and handle thousands of customer
complaints.

When the basic metrics and alerts are covered and tested, it is time to
implement a truly valuable metric &mdash; a metric that can track the happiness
of your users. This is usually much harder to measure, but you should at least
make sure that you have covered the simplest things &mdash; how many clicks does
it take to use the new feature, how long does it take to set it up, and what is
the ratio of users who have tried, succeeded, or dropped of in the process.

## Announcing the new feature

You should now be fairly confident that your new feature is good enough to be
used by real people. It is time to let the world know.

First, you should make sure that you have notified everyone in the company that
a new feature is coming. That includes customer support who will suffer the most
if you have failed to make the software bulletproof, marketing folks who are far
more capable in bringing the new feature close to your users, and the rest of
the programming crew who might suffer if something breaks in the infrastructure.

Then, it is time to prepare a public announcement. I always like to start with
a simple blog post. Nothing too fancy, simply a "Hey guys, we produced something
new. Give it a try." post with several screenshots.  You don't need to be a
marketing/seo guru to do this, but you do need to take this step as serious as
the coding part.

When everything is ready, I click the "enable" button for my new feature,
publish the blog post, and write a short summary on Twitter.

My new feature is now live.

## Communicating with the users

Is everything ready new, can I start celebrating? Not so fast. Your new feature
has just be announced, how can you be sure that it is successful?

Tracking the behaviour of early adopters is a must. We must make sure that they
are happy with the change. Unfortunately, many of them won't be happy, people
don't like change, even if it a change for the better. Your task now is to
collect the feedback, improve, and collect even more feedback.

It is also totally acceptable to contact the early adopters, and ask for
feedback. Engineers are usually most afraid of this part, but you really
shouldn't be. This experience can be very rewarding and an excellent connect
your feeling with the feelings of your customers.

Being open and friendly is always the best way to go.

## Opening the bottle of the finest whisky


