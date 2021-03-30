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

It is important to be pragmatic while setting up your first loop. Choose a loop
that is already implicitly known by your team, and has established metrics.
While this loop might not be the most important one for your product, it is good
to gain some collective knowledge about the process, before you start digging
into deeper subjects.

## Real World example: Platform quality at Semaphore

At Semaphore, we had a KPI set up since the start of the product. This is the
"measurement" part of the feedback loop. What we missed was a systematic
approach for analysis and hypothesis collection. The important leap we did at
the start of 2020, was to establish a weekly rhythm for reviewing and storing
data.

We started with a feedback loop that had two important characteristics. A clear
metric that we can use, and a clear benefit for reviewing it on a weekly basis.
This was the quality of our job scheduling system.

<p style="text-align: center;">
  <img src="/images/2021-03-22-feedback-loop-metrics.png">
  <small style="margin-top: -5px;">Measurments of job scheduling performance</small>
</p>

The speed of job scheduling is one of the key metrics of a CI/CD system. It
tells us if our customers' pipelines are starting fast enough. Any delays in job
scheduling are directly hurting the productivity of the teams that rely on our
service.

The numbers we collect proved to be the best indicator if our capacity planning
calculations are correct. Green values mean that we have achieved our goals for
the last week. Red numbers mean that the system is loosing stability. We need
to scale our platform.

The next piece of the puzzle is an appropriate review rhythm, or in other words
how often are we collecting and reviewing the measurements. Using the same
review cycle for all feedback loops is a suboptimal strategy. Instead, we always
aim to pick one that matches the natural fluctuation of the product area.

<p style="text-align: center;">
  <img src="/images/2021-03-22-feedback-loop-rhythm.png" style="max-width: 60%; display: block; margin: auto;">
  <small>Weekly analysis of Build Platform every Friday 10am.</small>
</p>

For platform quality, we got the results if we scheduled a weekly review cycle.

<p style="text-align: center;">
  <img src="/images/2021-03-22-feedback-loop-tasks.png">
  <small>Results of weekly platform analysis.</small>
</p>

Every review cycle results in a set of problems and hypothesis how to solve
them. We use GitHub issues to collect observations.

## Why some feedback loops fail?

Feedback loops are a simple yet powerful tool if implemented correctly. On the
flip side, incorrectly implemented feedback loops can cause more harm than good.
Feedback loops that don't have clear metrics can often lead to frustration. You
need to have a objective data to make the right choices.

Even feedback loops that are properly set up can lead to frustration. Feedback
loops that are tracking low-level details produce lots of operational work, but
little impact in the overall state of the product.

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

**Avoid setting up a feedback loop for every detail**. Instead, focus on the
  largest possible scope that your team controls.

## High quality feedback leads to high quality products

It is surprising easy to slide down the wrong path, build features that nobody
wants, improving performance in the wrong place, or worry too much about
unimportant details. Without examining the feedback loops of our product we are
effectively flying blind.

Feedback loops influence everything from the tasks we do every day to the
happiness of the team that is working on the product. We can be the victims of
implicit feedback loops, or we can make a concious choice to design and mold
them.
