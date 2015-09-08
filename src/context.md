# Context

Computer Science is a young discipline, but even if young it drastically evolved
over a few decades. The diffusion of personal computers and the internet,
as well as mobile devices and cloud computing in the last years led to an
exponential increase of information technology related products and services
usage, thus incrementing also the necessity of productivity improvement in
software development organizations.

To overcome this requirement, different approaches have been implemented in
different areas of interest in software development (Table 2.1), in particular
in terms of new software architectures, changes in infrastructure and in the
workflow adopted during development.

                1990's             2000's            2010's
--------------  -----------------  ----------------  ---------------
Architecture    Monolith           Layered Monolith  Microservices
Infrastructure  Phisical Machines  Virtual Machines  Containers
Dev. Workflow   Waterfall          Agile             DevOps

Table: The evolution of Information Technology

This chapter provides an overview of how Information Technology evolved in these
categories and how both this thesis project and the *Gasista Felice* web
application represent the current state of the art.

## Evolution of software architectures

The first developed applications in the history of information technology
weren't equipped with a well defined software architecture. For simple, small,
applications, developed by few people (if not single developers), the absence of
a defined software architecture wasn't a problem, but in bigger projects this
absence often led to examples of so called *spaghetti code* (code with a
complicated structure, difficult to read and maintain), that brought entire
projects to failure. The situation improved when developers began to divide the
code using a modular approach, as suggested by the Unix philosophy @unix,
assuring reuse and a better maintenance of the projects.

### Model View Controller

Regarding web applications, a common adopted software architecture is the *MVC*
(Model View Controller), that consists in the separation of the application in
three distinct components:

- A model for the storage of the application data
- A view for displaying a representation of the data contained in the model
- A controller that acts as intermediary between the model and view,
  manipulating the model

A web application that adopts this pattern permits a good separation of
concerns, but is still a layered monolith application, and even if a layered
monolith application is divided in modules, often the code is not well
decoupled, thus leading to circular dependencies among them and thus rending
changes to a module more difficult and frustrating. A monolith application can
grow in a unexpected way, making the project hard (if not impossible) to
maintain.

### From MVC to Microservices

> *The term "Microservice Architecture" has sprung up over the last few years to
 describe a particular way of designing software applications as suites of
 independently deployable services.* @martinfowler-ms

In the microservices software architecture, the project is developed as a set of
small and lightweight services, that communicate amongst them through a well
defined API. These small services can be written in different languages, and
replaced when they are obsolete.

In addition of deployment advantages (such as scalability) of microservices
structured applications, in software development a microservices approach can be
seen as a new implementation of the Unix principles of modularity: the
services themselves acts as modules for a software, and are completely
independent.

In this thesis project the Gasista Felice web application has been
containerized, so its infrastructure and development process has been prepared
to embrace a migration to the microservices software architecture. In fact, the
container infrastructure is the key of development and deployment of
microservices structured applications.

## Software infrastructures and development environments

In the past web applications were deployed in physical machines, leading to
different problems in management and maintenance due to their physical and so
*static* constraints. Virtual machines permitted to resolve these problems,
delegating the management of the physical server machines to third parties, thus
freeing the organization from this duty.

While virtual machines emulate every aspect of the desired machine and operating
system, those features are heavy and often unnecessary, and that's the reason of
the diffusion of containers. Containers are lighter than virtual machines,
because they don't aim to reproduce an entire machine, but only the environment
required to run a particular software. The Docker container engine use the
virtualization features of the Linux kernel in order to reproduce a software
operating environment in a native and lightweight way. Thanks to their
lightweight nature, containers seems today to be the perfect infrastructure for
the development and deployment of applications with a microservices architecture.

In the development of a web application with a traditional infrastructure,
developers install all the required tools, such the database management system
or the application framework, in their machines, through the installation
procedures available for their operating system. These installation procedures
are complicated and frustrating, and distract the developers from the
development activity. In addition to that, the development environment created
trough the installation and configuration performed by a developer can be
different to the environment created by another developer due to the
differences between their operating systems, and these differences can lead to
difficulties when attempting to reproduce and fix a reported bug that is related
to a particular environment.

These problems led to the diffusion of virtualization tools, that permits to
formally define the development environment and his features, and to virtually
reproduce them in every machine. Virtualization can be obtained both with
virtual machines and containers.

After the containerization of the Gasista Felice application, this thesis work
will show how this change affects the whole development environment.

## Development Workflow

A classic development workflow is the *Waterfall* model, that consists in the
following steps (that can be adapted):

1. Requirements specifications
2. Design
3. Implementation
4. Verification
5. Maintenance

Given that the steps are executed sequentially, this model provides a very slow
development, integration and delivery process.

### Agile and Continuous Integration

A more modern model is provided in the *Manifesto for Agile Software
Development*:

> *We are uncovering better ways of developing software by doing it and helping
others do it. Through this work we have come to value:*
>
> - *Individuals and interactions over processes and tools*
> - *Working software over comprehensive documentation*
> - *Customer collaboration over contract negotiation*
> - *Responding to change over following a plan*
>
> *That is, while there is value in the items on the right, we value the items on
the left more.* @agile-manifesto

In the Agile model the highest priority is the customer satisfaction, reached
trough collaboration, and early and continuous delivery of the software
@agile-principles. In order to actually provide continuous delivery and
flexibility to changes, Continuous Integration is essential.

Continuous Integration is a practice where the members of the development team
integrates their work frequently (daily or even more frequently). Every
integration is verified by an automated system that download the last software
revisions, and run automated tests to verify the correctness of the application
in its entirety @martinfowler-ci.

This thesis work will cover the implementation of automated tests for the
Gasista Felice project and the installation and configuration of a Continuous
Integration system, as well as its integration with the container infrastructure
of Gasista Felice and with a SCM (Source Code Managament) system for automatic
triggering of the builds.

#### DevOps

DevOps @devops (Development and Operations) is an extension of the Agile
workflow that adds the priority of establishing a parity between development and
production environments and promotes collaborations between developers and IT
operators.

In this context Continuous Integration is associated with the Continuous
Delivery of the software product. Continuous Delivery consists in automatic
deploy of the software as soon as the Continuous Integration system verified its
correctness.

The necessity of a Continuous Delivery system is covered by this work with the
installation and configuration of the Continuous Integration system.

## Testing

There are different categories of automated tests, and in particular:

- Unit tests
- Integration tests
- End-to-end tests

Unit tests regard the testing of computational units. A computational unit can
be seen as the smallest testable part of an application (for example a class or
a method in OOP), and is performed by executing the unit with an input parameter
and evaluating the returned results, that has to be the expected. The value
expected as result should be hardcoded (the first error made by unexperienced
testers is to think that testing routines should do computation, while testing
routines have the role of calling program procedures with a set of fixed
parameters and comparing the return value with the expected).

Sometimes the called methods needs the interaction with an external component,
such as a database; in that case, the interaction with the component has to be
replaced with the interaction with a dummy object that usually has the role of
returning a fixed value.

Integration tests regard the testing a grouped set of modules in order to verify
their interaction. It can involve the interaction with external components, and
in that case, the testing environment has to be configured in order to permit
this interaction (for example an integration test that involve a database query
has to be executed in an environment provided with a test database).

End-to-end tests, sometimes called system tests, regard the testing of
application from the user point of view. For web application end-to-end are
implemented with browser automations scripts, that require the configuration of
a software that act as a driver for different browsers in order to make them
access the web application and test its features.

The chosen typology for starting the implementation of automated tests in the
Gasista Felice application is the last one, for different reasons:

- End-to-end tests operate in the outer layer of the application, thus have an
  higher probability of discovering bugs because they also trigger the
  executions of procedures in all the application underlying layers

- End-to-end tests can be used in order to ensure that the application
  requirements are correctly satisfied, and can be used in the interactions with
  the customer as demonstration of the implemented features

- Bugs discovered by end-to-end tests are the most evident for the customer,
  thus the most urgent

- Configuring the container environment to include containers for the testing
  framework will permit the running of end-to-end tests without additional
  configuration to be done by developers in the future, while unit tests can
  also be executed without additional configurations

A particular importance is attributed to the last point, because after the
containers configuration is done, developers can implement and run both unit and
end-to-end tests, opening the way for the Test Driven Development, the practice
of writing tests as specifications of a feature to implement, before actually
implement that feature. Before writing a new method, the developer can write a
unit test to verify its behaviour, and before implementing a feature requested
by the customer, a end-to-end tests can be written as specification of that
feature. With this approach, the last implemented features are also covered with
automated testing, drastically improving the quality of the software.

## Gasista Felice

Gasista Felice @gasistafelice is an online management application made for *GAS*
(Ethical Purchasing Groups) by the beFair team, and initially developed for
*DES* (Solidarity-based Economy District) Macerata.

Gasista Felice is the use case for the thesis work, and in particular, is
infrastructure, that will be containerized, and its *AngularJS* based web
interface, that acts as use case of end-to-end tests implementation.

The beFair team is involved in *Sharing Economy* @sharing-economy, that focuses
on a major interaction between providers and consumers, enhances the community,
creates discussion places, and provides direct feedback.

### Free Libre and Open Source Software

This work is made, in its entirety, with FLOSS (Free Libre and Open Source
Software), and is also released as FLOSS.

The beFair team is oriented to FLOSS principles, that are explained in detail in
by the *GNU* (GNU is Not Unix) project website:

> *“Free software” means software that respects users' freedom and community.
Roughly, it means that the users have the freedom to run, copy, distribute,
study, change and improve the software. Thus, “free software” is a matter of
liberty, not price. To understand the concept, you should think of “free” as in
“free speech,” not as in “free beer”. We sometimes call it “libre software” to
show we do not mean it is gratis.* @free-software

In fact, free doesn't mean gratis, but means that if the user obtains a copy of
the software, obtain also the right to do all the things listed above.

Free software ensures communication and collaboration with the customer,
transparency, reuse, better feedback and lower release times, so it's an added
value to a software product, and fits well with the Sharing Economy principles.
