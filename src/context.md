# Context

Computer Science is a young discipline, but even if young it drastically evolved
over a few amount of decades. The diffusion of personal computers and internet,
as well as mobile devices and cloud computing in the last years lead to an
exponential increase of information technology related products and services
usage, thus incrementing also the necessity of productivity improvement in
software development organizations. To overcome this necessity, different
development methodologies has been applied. These methodologies regard different
area of interest in the software development, and in particular three distinct
categories:

- Architecture
- Infrastructure
- Development Workflow

## Software architectures

The first developed applications in the history of information technology
weren't equipped with a well defined software architecture. For simple, small,
applications, developed by few (often one) persons, the absence of a defined
software architecture wasn't a problem, but in bigger projects this absence
often leaded to examples of *spaghetti code*, that brought entire projects to
failure. The situation improved when developers began to divide the code using a
modular approach, as suggested by the Unix philosophy @unix, assuring reuse and
a better maintenance of the projects.

### Model View Controller

Regarding web applications, a common adopted software architecture is the *MVC*
(Model View Controller), that consists in the separation of the application in
three distinct components:

- A model for the storage of the application data
- A view for displaying a representation of the data contained in the model
- A controller that acts as intermediary between the model and view,
  manipulating the model

A web application that adopt this pattern permits a good separation of concerns,
but is still a monolith application, and even if a monolith application can be
divided in modules, often the code is not well decoupled, thus leading to
circular dependencies among them and thus rending changes to a module more
difficult and frustrating. A monolith application can grow in a unexpected way,
making the project hard (if not impossible) to maintain.

### Microservices

 *The term "Microservice Architecture" has sprung up over the last few years to
 describe a particular way of designing software applications as suites of
 independently deployable services. While there is no precise definition of this
 architectural style, there are certain common characteristics around
 organization around business capability, automated deployment, intelligence in
 the endpoints, and decentralized control of languages and data.* @martinfowler-ms

In the microservice software architecture, the project is developed as a set of
small and lightweight applications, that communicate amongst them through a well
defined API. These small applications can be written in different languages, and
replaced when they are obsolete.

In addition of deployment advantages (such as scalability) of microservice
structured applications, in software development a microservice approach can be
seen as a new implementation of the Unix principles of modularity: the
applications themselves serves as modules for a project, and are completely
independent.

Even if the Gasista Felice application, the case of study of this thesis work,
hasn't a microservice software architecture, the work is aimed to predispose
its infrastructure and development process to embrace a future migration to this
new software architecture. Container infrastructure is the key of development
and deployment of microservice structured application.

## Software infrastructures and development environments

In the past web applications were deployed in physical machines, leading to
different problems related to their management and maintenance. Virtual
machines permitted to resolve these problems, delegating the management of the
physical server machines to third parties, thus freeing the organization of this
duty.

While virtual machines emulate every aspect of the desired machine and operating
system, those features are heavy and often unnecessary, and that's the reason of
the diffusion of containers. Containers are lighter than virtual machines,
because they don't aim to reproduce an entire machine, but only the environment
required to run a particular software. Docker containers use the virtualization
feature of the Linux kernel in order to reproduce a software development
environment in a native and lightweight way. Due to its lightweight nature,
containers are a perfect infrastructure for the development and deployment of
applications with a microservice architecture.

Regarding the development of the web application, often developers install all
the required tools, such the database management system or the application
framework, in their machines, through the installation procedures for their
operating system. These installation procedures are complicated and frustrating,
and distract the developers from the development activity. In addition to that,
the development environment created trough the installation and configuration
performed by a developer can be different to the environment installed by
another developer due to the differences between their operating systems, and
these differences can lead to difficulties when attempting to reproduce and
fix a reported bug that is related to a particular environment.

These problems leaded to the use of virtualization tools, that permits to
formally define the development environment and his features, and to virtually
reproduce them in every machine. Virtualization can be obtained both with
virtual machines and containers. This thesis work will cover the creation of a
standardized development environment for the Gasista Felice application through
the container based virtualization.

## Development Workflow

A classic development workflow is the *Waterfall* model, that consist in the
following steps (that can be adapted):

- Requirements specifications
- Design
- Implementation
- Verification
- Maintenance

Given that the steps are executed sequentially, this model provides a very slow
development, integration and delivery process.

### Agile and Continuous Integration

A more modern model is provided in the "*Manifesto for Agile Software
Development*" @agile-manifesto, that gives value to:

- Individuals and interactions over processes and tools
- Working software over comprehensive documentation
- Customer collaboration over contract negotiation
- Responding to change over following a plan

In the Agile model the highest priority is the customer satisfaction, reached
though early and continuous delivery of the software @agile-principles. The
Agile workflow promotes the embracing of the changes. In order to adopt an Agile
workflow, the Continuous Integration is essential.

Continuous integration is a practice where the members of the development team
integrates their work frequently (daily or even more frequently). Every
integration is verified by an automated system that download the last software
version, and run automated tests to verify its correctness @martinfowler-ci.
This thesis work will cover the implementation of automated tests for the
Gasista Felice project and the installation and Continuous Integration system
and its integration with the container infrastructure of Gasista Felice and with
a SCM (Source Code Managament) system.

# Delimiter

## Agile

### CI

## Testing

### Unit Tests

### Integration Tests

### Acceptance Tests

#### E2E

## Economical-social context

### FLOSS

### Sharing Economy

### Gasista Felice and beFair
