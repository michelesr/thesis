# Introduction

This work aims to cover the whole development process of modern web applications
organized in lightweight environments called *containers*. It shows how
development can be made easier with containers adoption, and how automated
testing with a good test suite, together with a Continuous Integration system,
effectively improve the software quality because they help in discovering bugs
and act by themselves as quality indicators.

A container is an isolated environment where an application resides and runs.
Containers can communicate to each other using a virtual network provided by the
*container engine*, which is also the software that creates and manage them. A
container based virtualization approach leads to different advantages in
production, in terms of scalability, reliability, automation, better management,
and rolling updates.

In the development of web applications, containers can be used to obtain a
development environment similar to the production environment, eliminating the
disadvantages arising from the differences between these two environments, such
as bugs related to different versions of one or more application components.
Furthermore, providing a containerized development environment helps the
reproduction of reported bugs, given that all the developers work in a
standardized, reproducible, and easy to obtain environment.

Part of the research work preceding the thesis consisted in comparing different
typologies of tests that could be implemented for a software, and finding the
most suitable and urgent for the case of study taken into account. The testing
typology chosen for this thesis work is *end-to-end*. End-to-end testing is the
testing of the final product, and its purpose is to simulate in a programmatic
way the user interaction with the application interface, in order to discover
bugs that are visible from the external. Those bugs are the same that the users
discover first, and thus the most urgent to deal with. End-to-end testing for
web applications involves systems to drive different web browsers, make them
interacting with the application and so ensuring that the application features
are working properly.

Regarding the testing of the software, there is a series of steps to perform in
order to adapt the testing process to the container based virtualization,
gaining the advantages of a standardized testing environment that is completely
reproducible. Often developers don't run integration and end-to-end tests on
their desktop or laptop machines because they don't want to configure the
testing environment, or different configurations can lead to different test
results. This work will cover the aspects of integrating the container approach
to the software testing, and will provide simple procedures to run all the
implemented tests without effort for the developers.

A *SCM* (Source Code Management) system is a software used to manage the source
code of one or more projects, registering every change and addition introduced
from its born to the last version. A Continuous Integration system is a software
that provides automatic check of software projects, building and testing the
applications at every revision. Tests can run in the developers machines, but it
is mostly important that they run also in a Continuous Integration system. Once
revision are uploaded in a SCM system, automated tests have to be run
(Continuous Integration), and if the tests pass, then the application can be
automatically deployed (Continuous Delivery), else, the deploy must abort and
developers have to be warned about the critical situation.

This work is the outcome of a collaboration with the *beFair* software development
team, that begun at the firsts months of 2015, when the team realized that
a boost in the quality of the development process and final product could be
obtained with the application of automated software testing, and, at the same
time, it decided to change the way applications are developed and deployed,
shifting from a traditional development and deploying approach, to a
containerized one.

*Gasista Felice* @gasistafelice, developed by the beFair team and released as
*FLOSS* (Free Libre and Open Source Software) @free-software, is the use case
for this work. Gasista Felice is an online management application made for GAS
(Ethical Purchasing Groups) initially developed for *DES* (Solidarity-based
Economy District) Macerata.

## Organization

Chapter 2 exposes the technological and social context that led to the thesis
work, as well as the motivation of choosing the end-to-end testing typology and
the container based virtualization.

Chapter 3 introduces and explains in detail the *Docker* @docker container engine,
with practical examples of usage, then it shows how the *Docker Compose*
@docker-compose container orchestration tool can be used to simply define
and build portable development and testing environments. The last section of the
chapter exposes the structure of Gasista Felice, as well as its configuration of
the development environment.

Chapter 4 covers the implementation of browser automation routines with the
*Protractor* @protractor framework for the end-to-end testing of *AngularJS* @ng
web applications, and in particular, of Gasista Felice AngularJS web client.

Chapter 5 shows the main tools used in end-to-end tests and how to configure the
testing framework to work with the Gasista Felice application container
ecosystem. The configuration is an integral part of this thesis and aims to
reduce the developer effort to get the testing environment.

Chapter 6 explains how to build a Continuous Integration system to provide
automatic run of tests once the code is updated and pushed into the project
repository. Continuous Integration is essential for Continuous Delivery and
rolling release of the software products.
