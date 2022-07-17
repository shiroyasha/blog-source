---
id: dbb3ecaf-9820-4845-af82-b3aaa5923d20
title: Pull Requests are a reflection of your engineering culture
date: 2022-07-17
tags: programming
image: 2022-07-17-pull-requests-are-a-reflection-of-your-engineering-culture.png
---

When engineers want to introduce a change to the system, they use pull requests
to package the change and present it to the rest of the team. A pull request
usually contains a title, a description, and a list of commits that aim to
change the system.

They are the core communication mechanism in your team. More precise than Jira
tickets, more pragmatic than any meeting, and more direct than any design
document. Take a random pull request from your team, and it will tell me more
about your engineering culture than any other metric.

## Comparing Good and Bad pull requests

A pull request should be easy to understand. It should be reasonably short. It
should be backed by clear, objective quality signals like green CI build and
code quality metrics.

Bad pull requests are unclear. They don't have clear answers to "why are we
doing this?" and "why are we doing it like this?". They are usually unreasonable
in size and include multiple changes to multiple subsystems. The reader is
typically unsure if the pull request is mergeable, nor does he have any metric
to help answer this question.

## Write clear titles 

Clear titles that signal what this pull request is about to
introduce. Typically, this is a combination of business needs and concrete
implementation approaches.

As with other forms of writing, there is no precise formula for titles. It is
one of those things that you recognize when you see it.

Let's look at some examples:

-  "Change src/scheduler.go" - A good indication of poor communication patterns in
the team. Usually, these are individual contributors who rarely work in a
structured group.

- "Update the for loop in the scheduler implementation by counting in reverse and
visiting memory objects in a FIFO order" - Technically precise, but low
information about the reason for this change. Usually, an indication of poor
communication in the team and can be a signal of superhero culture.

- "Optimization of the scheduling strategy" - Good high-level technical overview,
but still low information about the reason for this change. Typically, it arises
in teams disconnected from the company's business decisions.

- "Optimization of the scheduling strategy to reduce server hosting costs -
Excellent! Good technical description and direct reason for this change. 

## Focus on the reason for change in the description

Every change to the system has two parts: the *why?* and the *how?*.

The *how?* should be clear from the code. Either write clean and understandable
code or supplement the code with documentation that describes the implementation
details.

As the code focuses on the *how?*, there is little reason to supplement this
same information in the pull request description. The description should
describe the details of why we are introducing this change.

For example, here is how a good PR description should look like. 

> We have noticed increased server hosting costs in the previous
> quarter that were not matched directly by increased demand on the system. We
> have noticed that the scheduling system is introducing delays by not efficiently
> visiting the objects. This PR addresses this concern and aims to reduce the
> server hosting costs by up to 5%.

Notice that it focuses on the reason and not the implementation.

## Supplement PRs with results and visual proof 

Pull Request reviewers will typically question your approach to solving the 
problem or might be unsure of the results.

Provide results or visual proof when submitting pull requests. In our previous
scheduling example, provide metric data that supports your argument. In visually
centered systems, like updates in the UI, provide screenshots or videos of the
new design. 

## Keep the Pull Requests short and to the point 

I have a rule of thumb in my team. Pull requests should be short in length 
(typically around ~300loc), short in age (0-3 days to write), and focused on one change.

Typically, a pull request starts by updating tests, followed by several commits
that attempt to implement the new system specification.

Long pull requests are typically a signal of either young engineers who are
still learning the value of short and safe iterative changes or overly eager
changes to the system that is impossible to review and approve.

The actual number of line changes depends on multiple factors. The previously
mentioned ~300loc fits my team and our design. Some languages are less
expressive, and some changes require more work and cannot be broken down. 

Breaking these guidelines once in a while is not a problem. The problem arises
when suboptimal patterns take over and degrade your engineering culture.

## Keep the coding style uniform and objective 

Young engineering teams tend to put a lot of emphasis on how the code looks and 
how it is formatted. Older teams usually have a shared understanding of what 
good code looks like and spend less time discussing it.

Keeping the code clean has clear benefits. But discussing this in every pull
request degrades the quality of discussion and exhausts the energy that remains
for vital topics.

Use a linter, codify your rules, and make it part of the CI process. There
should be no reason to check the code style in every pull request manually.

## Don't review pull requests before CI 

The CI should be your first reviewer. There is no reason to involve other humans
before you get a green build from your CI system.

Teams that lack fast CI, or even worse, lack CI entirely, tend to lose a lot of
time repeating and manually validating the same problem areas over and over.

An engineering culture that lacks automated Pull Request reviews is an insane
amount of energy and money on entirely automatable problems.

## Tips for engineering leadership 

It is understandably hard to step out from thinking about long-term strategy and 
zoom in on a single pull request. However, by missing to do this occasionally 
(once a quartal, for example), you are missing out on valuable insights about
your engineering culture that are hard to reproduce in any other way.

After all, it has been repeatably shown that your organization's operational
performance directly impacts its overall performance.

My advice is to go to your main project, take a random pull request, and get a
direct first-hand experience of the bottlenecks your team is dealing with.
