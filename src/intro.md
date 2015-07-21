# Introduction

## Context

### The evolution of software architecture

Over the last few years the software architecture has shift from service based architecture toward smaller micro services.

The approach of microservice develop a single application as a set of small services, each one running in its own process and communicating with simple API (Application Programming Interface).

In the past, the applications followed monolithic architecture style, that means that were a unique complex unit. Web applications, for example, where built in three main parts:

- a client-side user interface (html, css, javascript), also called frontend
- a database
- a server-side application, also called backend

But this approach is not suitable to distribute the service in a scalable way. For example an update on a small components of the application require a rebuild and deploy of the entire monolithic application.

In order to reach a microservice approach, the first step to do is to divide the applications in containers, and manage them with a container engine, such as *Docker*.

### Containers for production and development

Container are isolated environment that contains applications, and can communicate with each other using a virtual private network.

In production, if the containers are combined with a container orchestrator, a lot of advantages can be obtained, such as scalability, resource on-demand, rolling release, and replication.

For the developers, containers can be used to obtain a development environment similar to the production one, eliminating the disadvantages arising from the differences between these two environments, such as bug related to different version of an application components, or related to difference between the web server used in the environments.

Regard the testing of the software, there is a series of steps to perform in order to adapt the testing process to the container based architecture, but this architecture provides a standardized testing environment that is completely reproducible. Often developers doesn't run tests on his desktop or laptop machines because they don't want to configure the testing environment, or a different configuration can lead to different tests result. This is the problem that will be faced in this document.

### End-to-end testing

In addition to the configuration of the testing environment in a container based software architecture, this document will talk about the end-to-end testing techniques. End-to-end testing is the testing of the final product, and his purpose is to programmatically simulate the user interaction with the application interface in order to discover bug that are visible from the extern, that are the same bugs the users discover first.

### Continuous integration and delivery

Tests can run in the developer machines, but it is important that also run in a continuous integration environment. Once the code is pushed to a SCM (Source Code Management) system, a hook for automated tests has to be run, and if the tests pass then the application must be automatically deployed (continuous delivery). If the tests don't pass, the deploy abort and developers have to be warned about the critical situation.

This thesis will cover a implementation of a system like this, using the most recent tool realized for the purpose. These tools provide support for container based architecture, so they fits particularly with the design choices of our projects.

### Use cases

#### Gasista felice

*Gasista felice* @gasistafelice is an online management application made for GAS (Ethical Purchasing Groups) made by the beFair team, and initially developed for *DES* (Distretto Economia Solidale) Macerata.

Gasista felice will be the main use cases for end-to-end testing, and in particularly, the focus will stay on his new, responsive and mobile friendly web-interface, based on *AngularJS* framework by Google.

#### Social Business Catalog

*Social Business Catalog* @sbcatalog is an aggregator, a showcase and an API for suppliers and products of the social business. SBcatalog offers:

- *a web interface, nice and simple for consultation on PCs, tablets and smartphones*
- *an API that allows programmers to upload and download the catalogs of suppliers with which they are related*
- *integration with the national portal of the solidarity economy*

Integration tests has been conducted for this application and will be used as example in the overview of integration tests.

The web interface of sbcatalog is made with AngularJS, and will be used a use case for end-to-end tests.

## New Economy

My collaboration with the beFair team begins at the first months of this year, when the team realized that a boost in the quality of the development process and final product could be obtained with the application of automated software testing.

### beFair

The *beFair* team is an organisation that bases its root in the following principles @befair-theproject:

- Develop the territories with technologies, methods and practices for society ethics and solidarity

- Offer tools and technology solutions with Free Software, favoring network strategies to make life easier and increase the effectiveness of activities.

- Adopt an agile development process in order to maximize efficiency and flexibility of the products

### FLOSS

This work is made, in its entirety, using FLOSS (Free Libre and Open Source Software) and also will be released as FLOSS.

As a team, we think that in the contemporary context, the software that we develop has to follow the FLOSS (Free Libre and Open Source Software) principles, that are explained in detail in the *GNU* project website @free-software:

> *“Free software” means software that respects users' freedom and community. Roughly, it means that the users have the freedom to run, copy, distribute, study, change and improve the software. Thus, “free software” is a matter of liberty, not price. To understand the concept, you should think of “free” as in “free speech,” not as in “free beer”. We sometimes call it “libre software” to show we do not mean it is gratis.*

In fact, free doesn't mean gratis, but means that if the user obtain the software, it has also the right to do all the things listed above.

Free software ensures software reuse, better feedback and lower release times, so it's an added value to our products.

<!-- Free software lays the foundations for an era in which there will be no more secrets and patents, but the ideas will be made available to all immediately, placing the collective interest above that of a few select individuals. Free Software is shared knowledge, that use the network as a tool for spreading. -->

### Social Business

We also follow a social business model @social-business, that means:

- *Business objective will be to overcome poverty, or one or more problems (such as education, health, technology access, and environment) which threaten people and society; not profit maximization.*
- *Financial and economic sustainability*
- *Investors get back their investment amount only. No dividend is given beyond investment money*
- *When investment amount is paid back, company profit stays with the company for expansion and improvement*
- *Gender sensitive and environmentally conscious*
- *Workforce gets market wage with better working conditions*
- *...Do it with joy*

Social business focuses on relationships, it strengthens the community, creating places of discussion and debate and providing fast feedback.

### Agile development process

Another mainstay of the beFair team is the agile development process, that is described in the *Manifesto for Agile Software Development* @agile-manifesto. The main points of agile development process are:

- *Individuals and interactions over processes and tools*
- *Working software over comprehensive documentation*
- *Customer collaboration over contract negotiation*
- *Responding to change over following a plan*

In this manifesto, priorities are given in the development process, but the concepts with lower priority remain fundamentals. Agile means embracing the change, over following a plan, that fits the client needs in a more direct way. In this context, automated tests are necessary in order to achieve continuous delivery of the product.

## Organization of this document

Chapter 2 exhibits the main typologies of automatic tests with example, starting from unit tests, going through integration tests and finally introducing the end-to-end tests.

Chapter 3 talks about how Docker Engine and Docker Compose can be used to easily reproduce an environment similar to the one deployed in production in order to make developers life better, and the main advantages of this approach compared to the use of Vagrant. This chapter will also expose the motivation that leads to the choice of this instruments and will show the architecture of the software that will be tested.

Chapter 4 shows the main tools used in end-to-end tests, how to configure them to work with the container ecosystem. The configuration is an integral part of this thesis and aims to reduce the developer effort to get the testing environment.

Chapter 5 will cover the end-to-end test techniques used for ensure a better quality of the tested software. Testing often reveals bad design choice made during the development process, so this chapter will also give some advice to how to write a better software and better tests.

Chapter 6 will explain how to build a Continuous Integration system to provide automatic run of tests once the code is updated and pushed into the project repository. Continuous integration is essential if we talk about continuous delivery and rolling release of the software products.
