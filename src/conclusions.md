# Conclusions

This thesis describes the organization of a web application in a container based
infrastructure, and the configuration of development, testing and Continuous
Integration environments for that application.

The configuration of the development environment containers is an added value
for the team because permits its developers to work in a standardized,
reproducible, and easy to obtain environment, allowing them to never worry
again of installation procedures and operating systems related problems, and
thus increasing their productivity. This benefits act also as an incentive
to external collaborations, because the effort to start the development is
reduced.

The configuration of the end-to-end test environment containers predispose the
possibility for the developers of writing end-to-end tests that can be executed
without additional configurations, and those tests can be used to reproduce
reported bugs and verify their resolution, as well as specifications of new
features to implement.

The implemented end-to-end tests give more value to the software product because
they verify the correctness of the main features of the application user
interface, can be used as demonstration for the customer, and give security to
developers when applying changes to code covered by automated tests.

The implemented Continuous Integration solution increases the productivity of
the entire team, giving rapid feedbacks for every change introduced in the
software, and testing the application in a context similar to the production
environment.

All the implemented solutions runs in containerized infrastructures, so this
thesis demonstrates how working with containers can be easy and productive.

The future developments regard the reorganization of the Gasista Felice
application to a microservices architecture, that can be easily obtained thanks
to the migration to a container based infrastructure, and the extension of the
implemented Continuous Integration system to provide integration with git server
advanced features (such as the automatic testing of the incoming pull requests),
to improve even more the productivity of the development team. The implemented
Continuous Integration system can be integrated with the production stack in
order to provide Continuous Delivery, and this will be done soon as the
production stack is predisposed to the container infrastructure.

A good part of this work is flexible and can be reused in the development of
other applications, so further developments are left to the imagination.
