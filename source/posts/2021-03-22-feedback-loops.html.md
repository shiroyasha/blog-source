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

## Designing a feedback loops

We will design a feedback loops that consists of three stages:

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

## How to set up your first feedback loop in the company?

Start small, be programmatic, measure things that have the biggest impact.

## How we implemented feedback loops at Semaphore?

Feedback loops at Semaphore.
What did we learn? What could we do better?

----

Other articles?...

Feedback loop Anti-Patterns.
The team that sets up the feedback loop, is not the one who runs it.

Explain types of feedback loops.

- Feedback loops that aim to make a breakthrough.
- Feedback loops that keep a system stable.
- Feedback loops that break aim to stop a crumbling system.

How to design feedback loops that aim to make a breakthrough.
How to design feedback loops that aim to keep a system stable and growing.
How to design feedback loops that aim to stop a crumbling system.
