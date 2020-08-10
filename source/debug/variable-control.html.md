---
title: Variable Control
---

When facing a tough issue that doesn't have a well defined origin the size of
the problem space can feel overwhelming.

Writting down all the known variables in the system can bring clarity and help
you to establish control.

## How to use it

1. Set up a spreadsheet and list all the known variables in your system that
have a probability of causing the reported bug.

2. Choose a set of values and run a test on your system.

3. Write down the exact time and values for each each test run.

4. Use the results to pinpoint the cause of the bug, or to eliminate possible
   causes.

## Practical example

An application has a form for user registrations. In the registration form, the
user needs to enter his name, age, and attach an avatar.

Some registrations are not processable by our system, but we don't understand
the root cause of the problem.

We will set up a variable control spreadsheet and write down track down the root
cause of the bug.

| Variable                   | 13:58          | 14:05          | 14:15          | 14:23          | 14:30          |
| -------------------------- | -------------- | -------------- | -------------- | -------------- | -------------- |
| Browser Version            | Firefox 77     | Chrome 80      | Chrome 80      | Chrome 80      | Chrome 80      |
| Name of the user           | Peter          | Peter          | Peter          | Peter          | Peter          |
| Size of the attached image | 2mb            | 2 mb           | 2 mb           | 2 mb           | 2 mb           |
| Backend instance           | 103.10.0.19    | 103.10.0.15    | 103.10.0.15    | 103.10.0.15    | 103.10.0.15    |
| User OS                    | MacOS Catalina | MacOS Catalina | Ubuntu 20.04   | MacOS Mojave   | Windows 10     |
| Issue Reproduced?          | No             | Yes            | No             | Yes            | No             |

The above chart is pointing us in the direction of Chrome 80, and MacOS.
