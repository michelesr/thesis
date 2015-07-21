# Introduction

## Context

### Improvement of software products and development process

In order to improve beFair software products, we have adapted our software architecture to fit the microservices model, that emerged out recently and became a standard for many organisations, such as *Google* and *Red Hat*. 

This approach divides the application in isolated microservices that live inside containers, and communicate through a Virtual Private Network (VPN). Containers are a evolution of virtual machines and provide many advantages if used in production.

...

### Use case: Gasista felice

*Gasista felice* is an online management application made for GAS (Ethical Purchasing Groups) to 

Gasista felice will be the main use cases for end-to-end testing, and in particularly, the focus will stay on his new, responsive and mobile friendly web-interface, based on *AngularJS* framework by Google.

## Context: New Economy

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

In this manifesto, priorities are given in the development process, but the concepts with lower priority remain fundamentals. Agile means embracing the change, over following a plan, that fits the client needs in a more direct way. In this context, automated tests are necessary in order to achieve continuous delivery of the product. This document will give a overview of all the typology of testing technique used in the context of software engineering, and will focus particularly on end-to-end testing.




## Organization of this document
