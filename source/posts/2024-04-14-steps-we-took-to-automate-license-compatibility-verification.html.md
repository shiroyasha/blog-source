---
id: c5440dbe-7e96-4b1f-a417-fc05d90964ea
title: Steps We Took to Automate License Compatibility Verification
date: 2024-04-14
tags: programming
image: 2024-04-14-steps-we-took-to-automate-license-compatibility-verification.png
---

We are actively developing Operately, an open-source software licensed under
Apache 2.0. As such, we need to carefully consider whether our dependencies'
licenses are compatible with ours. Starting to build features based on
functionality from a non-compatible license, only to realize this too late,
could lead to wasted time and energy in rewriting those features.

As we are a small team, my attention is intensely focused on building and
refining the core features of Operately. Whenever possible, I take
opportunities to automate tasks that can save significant time in the coming
months. One question arises: can license compatibility checks be automated to a
reasonable degree within a day's work, with a return on the time invested over
the next few months? I implemented such a system a few months ago at Operately.
The return on investment has been decidedly positive, and on several occasions,
it has prevented me from proceeding with features based on an incompatible AGPL
license—a scenario that could have cost me weeks or even a full month of work
if not caught early.

My requirements for a license compatibility checking system are as follows:

1. **Integration into the CI Build & Test Phase**: The system should be
   integrated into every continuous integration (CI) run. Whenever someone
   pushes code or opens a pull request, the system must provide a clear YES/NO
   answer regarding license compatibility. I prefer this real-time check over
   asynchronous systems that only notify of issues after code submission.

2. **Comprehensive Dependency Testing**: The solution must be capable of
   testing not only direct dependencies but also their nested dependencies
   recursively. It is crucial that it supports Elixir libraries and NPM packages,
   given that Operately is developed with a combination of Elixir and React. While
   Docker build compatibility would be beneficial, it is not essential.

3. **Open-Source**: The solution should be open-source. We are committed to
   supporting and utilizing open-source solutions, aligning with our principles
   and contributing back to the community.

[Pivotal’s License Finder](https://github.com/pivotal/LicenseFinder) is an 
excellent solution that meets most of our needs. It is a Ruby-based CLI tool 
that can be installed in our repository and integrated into our continuous 
integration build process. It is compatible with Elixir Mix and NPM, which are
essential for Operately, given our use of Elixir and React. Additionally, it 
supports many other programming languages and build systems, offering flexibility
should we decide to incorporate other technologies into Operately in the future.

The initial setup of the License Finder can be complex as it involves listing
all the dependencies in your projects and requiring approval for each
discovered license. Here’s the strategy I recommend:

1. **Approve MIT and BSD Licenses**: These licenses are well-established,
   clearly written, and have judicial precedence confirming their compatibility
   with the Apache 2.0 license. Approving these is straightforward.

2. **Assess Other Open Source Licenses**: Navigating other open-source licenses
   can be more challenging. [OpenSource.org](https://opensource.org/license) lists 
   at least 10 pages of recognized open-source licenses. Some, like GPL3 and AGPL, 
   are not compatible with Apache 2.0 and are considered restrictive or even
   parasitic. Others, such as Unlicense or WTFPL, lack clear legal status and
   are potentially problematic. Since I'm not a lawyer, we have decided not to use
   such licenses.

3. **Handle Unknown Licenses**: License Finder sometimes cannot identify a
   license for a dependency, like with TipTap used for rich text editing. In
   these cases, License Finder allows for the manual approval of packages. It
   requires you to specify your identity, the basis of your authorization, and
   the reason for approving the use of the license.

4. **Deal with License-Less Dependencies**: Many public repositories on GitHub
   are intended to be open-source but lack a clear license, making their use
   legally risky. I recommend removing these dependencies or contacting the
   contributors to obtain permission to use their software.

5. **Automate the Process**: Once you have approved all licenses, you can
    automate the process by running License Finder in CI. It will check all
    dependencies and provide a report on the licenses used. If a new dependency
    is added, License Finder will notify you of the new license, allowing you to
    approve or reject it.

Once the setup and initial license triage are completed, this system requires
almost no maintenance. It will continuously check every new dependency and every
update to your existing dependencies in the background.

**A note of warning:** While this system is great at detecting most license
incompatibilities, it is not infallible. I recommend a periodic manual reviews 
of all your dependencies, particularly for infrastructure software that this 
solution does not cover.

By investing a day in setting up the License Finder, I have saved myself weeks
of potential rework and legal headaches. I highly recommend this system to
anyone working on open-source projects, especially those with a small team and
limited resources. It is a small investment that can prevent significant
headaches down the road.

---

Investing time and energy into automation can yield long-term benefits, but there
is a risk of automating too much too early. For instance, for an early startup
like Operately, it makes sense to automate processes that can provide positive
outcomes within the upcoming quarter and can be completed in under a day.
However, it would be unwise to spend several weeks on automation efforts that do
not promise returns in the foreseeable future.

Finally, if you want to look at the specifics of how we implemented this check,
start from here: [Operately Makefile](https://github.com/operately/operately/blob/main/Makefile#L216).
