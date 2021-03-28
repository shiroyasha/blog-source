---
id: f7788acb-e6ba-43eb-9a4a-4ce86e7ee4e0
title: Feedback Loops
uptitle: "The backbone of product development teams"
subtitle: "A framework that enables us to experiment often, act fast, and to make <br>high-quality decisions independently."
date: 2021-03-22
tags: tech-lead
image: 2021-03-22-feedback-loops.png
---

<img src="https://www.homesciencetools.com/content/images/assets/FruitRipenStep4.jpg">

There is a surprising effect in nature where a tree or bush will suddenly ripen
all of its fruit or vegetables, without any visible signal. If we look at an
apple tree, with many apples, seemingly overnight they all go from unripe to
ripe to overripe.

This will begin with the first apple to ripen. Once ripe, it gives off a gas
known as ethylene (C2H4) through its skin. When exposed to this gas, the apples
near to it also ripen. Once ripe, they too produce ethylene, which continues to
ripen the rest of the tree in an effect much like a wave.

If you have an unripe avocado or other fruits at home, try putting them in a
paper bag with a ripening banana. This will speed up the ripening of the avocado
because ethylene emitted by the ripening banana will trigger the climacteric
response in the avocado. This strategy works best when the ripening fruit is one
that emits a high concentration of ethylene, such as an apple, pear, banana,
or passion fruit.

This feedback loop is often used in fruit production, with apples being exposed
to manufactured ethylene gas to make them ripen faster.

## Feedback loops for software products

Here is a fact: Most teams, most of the times, don't know where they are
stand on projects that are important to them.

Software teams want to increase software stability, but they don't collect bug
reports from their systems. Engineers want to make their software faster, but
they don't have a baseline of the current performance, nor a target they want to
reach. Companies want to have more customers, but they don't track signups, nor
do they analyze the failed ones.

My take is that we should play an active role in the feedback loops that shape
our products.

Products that fail to self-examine tend to few lucky successes and many
invisible failures. These failures that are left untreated tend to anchor them
down, and keep them spiraling in a downright trend.

Hopefully, the reverse is also true. Products that carefully design and
monitor their feedback loops recognize and monitor the threats, and act on
opportunities faster.

Here are few examples:

- **Want to improve the performance of your application?** Start measuring the
  99th percentile of your key pages. Analyse the numbers with the product team
  every Wednesday at 14:00. Introduce changes in the product. Repeat until the
  goal is reached.

- **Want to improve the product onboarding experience?** Collect every signup,
  group them into categories [success, failure] / [slow, fast] / [paid, free].
  Analyse the bottlenecks every Friday at 10:00am. Repeat every Friday.

- **Want to reduce number of Pager calls?** Count the number of Pager calls/week.
  Review the numbers every Monday at 3:00pm. If the numbers cross a threshold,
  kick-start a dedicated sprint.

## Types of feedback loops

A feedback loop consists of three stages:

1. Build: We build our software by building hypothesis.
2. Measure: We measure our outcomes, trying to be as objective as possible.
3. Learn: We analyze the metrics, learn, and build new hypothesis.

<img src="/images/2021-03-22-feedback-loops.png">

In regards to product development, we can divide feedback loops into three
distinct types:

**A balancing feedback loop** Where the goal is to maintain the desired state
of the system. Product uptime, performance of the system, and number of defects
per week are good examples of balancing feedback loops. Our goal is to establish
a baseline, measure the system continuously, and adapt in case of problems.

**A corrective feedback loop** Where the goal is break negative patterns that
are spiraling the system down a undesirable path. Preventing the spread of
negligent software patterns, introducing code quality tests, and restricting
access to privileged data are good examples. Our goal is to restore a failing
system into a stable system that can be monitored with a balancing feedback
loop.

**A progressive feedback loop** Where the goal is improve the system
continuously until a desired state is achieved. Increasing the market reach of
a product, releasing a new feature, or running an R&D project are a good
examples of progressive feedback loops. We don't yet know what the system can
achieve, our goal is to be better every day.

<img src="/images/2021-03-22-feedback-loop-types.png">

The type of a feedback loop dictates the main variables in our design. Balancing
and corrective feedback loops often have well defined metrics, while a
progressive loop usually needs to explore the which metrics to track.

The review/analysis rhythm also tend to differ. For balancing feedback loops the
status quo is the desired state, while progressive and corrective feedback loops
are yet to reach a stable state.

## How to set up your first feedback loop in the company?

Feedback loops are already implicitly present in every product. Your task is to
make them explicit. To do this:

1. Find an area where you want to improve
2. Find a set of measurements to follow
3. Establish a review rhythm

Here is one example of a balancing feedback loop from our teams at Semaphore.
We measure the quality of scheduling in our system.

<p style="text-align: center;">
  <img src="/images/2021-03-22-feedback-loop-metrics.png">
  <small style="margin-top: -5px;">Measurments of job scheduling performance</small>
</p>

Green values mean that we have achieved our goals for the last week. Red numbers
mean that the system is loosing stability, and most likely we need to scale our
platform.

<p style="text-align: center;">
  <img src="/images/2021-03-22-feedback-loop-rhythm.png" style="max-width: 60%; display: block; margin: auto;">
  <small>Weekly analysis of Build Platform every Friday 10am.</small>
</p>

<p style="text-align: center;">
  <img src="/images/2021-03-22-feedback-loop-tasks.png">
  <small>Results of weekly platform analysis.</small>
</p>

## Why feedback loops fail?

Avoid these common anti-patterns:

**Avoid "All or Nothing" mentality**. Setting up a feedback loop for every
    team and every feature will certainly take months, and will often yield
    suboptimal results. Introducing new, untested practices, company wide is
    asking for trouble. Start small and iterate.

**Avoid ambiguous metrics**. The point of feedback loops is to have
    measurements that are as objective as possible. A common example is "Uptime
    as reported by John, the team lead", where John decides what he considers a
    downtime.

**Avoid waiting for perfect metrics**. Avoiding ambiguous metrics pushes some
    teams into the opposite direction. They postpone any building until they
    fully objective numbers. Don't reject clear signals just because they have
    errors.
