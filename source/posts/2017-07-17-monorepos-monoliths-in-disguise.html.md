---
id: 44ed38c0-ed32-447e-8e0f-1d0479e41867
title: "Monorepos: Monoliths in Disguise"
date: 2017-07-17
tags: programming
image: monorepos.png
---

Your project and organization are getting bigger, and you start to notice that
your monolith is getting out of hand. Trying out new technologies is out of
question. You are stuck with the same language and platform from 5 years ago.
Microservices are here to save the day! You decide to expose an internal API,
and limit development of new features exclusively as microservices.

Your first attempt to write a microservice is good. Not great, simply good
enough. You didn't figure out how to write good end-to-end tests that
include both your monolith and the new service, but you are certain that you
will solve this issue in the near future. Deployment is also a bit troublesome.
It takes you several days to deploy your service, but again, you are almost sure
that next time you can do it better.

With the success of the first service, you write another one, and then another
one, and then after several months you have a handful of success stories. You
are trying out new languages, new frameworks, even going as far as to to try out
different database engines. Everything works great, or almost great. Deployment
of new services is still a bit slow, however it is much faster than several
months ago.

At this point, things start to get a bit out of control. You have several important
unsolved technical debts on your hands, and you realize that you need to solve
them in order to regain the trust in your system. You want fast deployment, easy
end-to-end tests, and a simple way to spin up completely new clusters.

Someone suggests that you should try to put all of your services in one repository.

![Monorepos: Monoliths in disguise](images/monorepos.png)

This is where it all begins. The rise of your monorepo.

Everything looks great. You create a dedicates directory for each of your
services, and commit them all at once. At the root of your repository, you
create a `docker-compose.yml` file, and precisely lay out the structure of your
infrastructure. You can't believe that it is so simple.

End-to-end tests are now a just a set of fancy tests that starts by spinning up
your docker compose cluster and running some code that verifies various actions
in your cluster. Finally! Life is easy again! For several months, you have
stopped practicing behaviour driven development, but now, with this new approach
for writing end-to-end tests you can put your BDD skills back in practice.

Deployment is also simple. You write a script in the root of your repository
that runs `docker build` in each service subdirectory. After that, the script
pushes the docker images to DockerHub. Finally, you trigger a new deployment for
each docker image that was changed. The problem of deployments is fixed, a
service simply needs to provide a docker file, and you can trigger the `./deploy`
script in the root of your repository to deploy it. Wicked!

You notice that creating new databases, managing migrations, and updating data
is hard. It would be nice if we could automate these steps. What if we use one
database for multiple services, someone asks in your team. You have good
end-to-end tests that will protect you from changes in your schema, so why not.
Of course, you will now have to deploy all the services that depend
on your database at once when you change something in your schema.

Developing new features often requires changes in multiple services. You need to
change some services to introduce new UI elements. You need to change
some other services to extend the data models in your system. To be fair, the
most logical solution at this point is to open a new pull request in your
monorepo that changes all the necessary services in your system and merge all
the changes at once.

Individual team ownership of services slowly crumbles. The new philosophy is
collective ownership of the monorepo. Everyone reviews everything, and everyone
takes part if something brakes. Deployment is sequential. When someone changes
one service he merges the changes into the master branch. If someone else
changes another service, he need to wait for the previous build on the master
branch to complete.

Several month in with your new monorepo approach, you notice something strange.
Every service in your system is deployed at once. Changes in one service
directly affect other services. You need to synchronize with every other
developer when you want to introduce changes in one of your services. Everyone
is responsible for the health of the monorepo, so in practice, no one is
responsible.

Welcome back to square one. Your system is a big docker based monolith.
