# Introduction 

My collaboration with the *beFair* software development team begins at the
firsts months of this year, when the team realized that a boost in the quality
of the development process and final product could be obtained with the
application of automated software testing. Testing helps discover bugs, and
contributes to the increment of the software quality, and in particular, the
tests suite itself performs the function of quality indicator. There are
different typologies of tests to implement, and part of this work consists of
comparing these typologies and find the most suitable and urgent for the team
projects.

As the title suggest, this work will focus on *end-to-end* tests. End-to-end
testing is the testing of the final product, and its purpose is to simulate in a
programmatic way the user interaction with the application interface, in order
to discover bugs that are visible from the external. Those bugs are the same
that the users discover first, and thus the most urgent to deal with. End-to-end
testing for web applications involves systems to drive different web browsers,
make them interact with the application and ensure that the application
functions are working properly.

At the same time, the beFair team decided to change the way applications are
developed and deployed, shifting from a traditional approach, to a container
based one. A *container* is an isolated environment where an application resides
and runs. Containers can communicate to each other using a virtual network
provided by the *container engine*, which is also the software that creates and
manage them. A container based approach leads to different advantages in
production, where provides scalability, reliability, automation, better
management, and rolling updates. For the developers, containers can be used to
obtain a development environment similar to the production one, eliminating the
disadvantages arising from the differences between these two environments, such
as bugs related to different versions of one or more application components. For
example the web server application used in production could be different (or a
different version) from that used in development.

Regard the testing of the software, there is a series of steps to perform in
order to adapt the testing process to the container based architecture, gaining
the advantages of a standardized testing environment that is completely
reproducible. Often developers don't run integration and end-to-end tests on
their desktop or laptop machines because they don't want to configure the
testing environment, or different configurations can lead to different test
results. This work will cover the aspects of integrating the container approach
to the software testing, and will provide simple procedures to run all the
implemented tests without effort for the developers.

Tests can run in the developers machines, but it is important that they run also
in a continuous integration environment. Once the code is pushed to a *SCM*
(Source Code Management) system, a hook for automated tests has to be run
(continuous integration), and if the tests pass, then the application must be
automatically deployed (continuous delivery). If the tests don't pass, the
deploy must abort and developers have to be warned about the critical situation.

*Gasista Felice*, developed by the beFair team and released as *FLOSS* (Free
Libre and Open Source Software), is the use case for the work.  *Gasista Felice*
is an online management application made for GAS (Ethical Purchasing Groups)
initially developed for *DES* (Solidarity-based Economy District) Macerata.

## Organization

Chapter 2 is the context.

Chapter 3 introduces and explain in detail Docker container engine, with
practical examples of usage, then shows how Docker Compose container
orchestration tool can be used to simply define and build portable development
and testing environment. The last section of the chapter exposes the structure
of Gasista Felice, as well as its configuration of the development environment.

Chapter 4 will cover the end-to-end test techniques used to ensure a better
quality of the tested software. In particularly *AngularJS* applications will be
tested using *Protractor* testing framework. Testing often reveals bad design
choice made during the development process, so this chapter will also give some
advice to how to write a better software and better tests.

Chapter 5 shows the main tools used in end-to-end tests and how to configure the
testing framework to work with the container ecosystem. The configuration is an
integral part of this thesis and aims to reduce the developer effort to get the
testing environment.

Chapter 6 will explain how to build a Continuous Integration system to provide
automatic run of tests once the code is updated and pushed into the project
repository. Continuous integration is essential for continuous delivery and
rolling release of the software products.
