# Conclusions

This thesis describes the organization of a web application in a container based
infrastructure, and the configuration of a development, testing and Continuous
Integration environment for that application. 

The configuration of the development environment containers is an added value
for the application because permits developers to work in a standardized,
reproducible, and easy to obtain environment, allowing them to never worry
again of installation procedures and operating systems related problems, and
thus increasing their productivity. 

The configuration of a end-to-end test environment containers predispose the
possibility for the developers of writing end-to-end tests that can be executed
without additional configuration, and those tests can be used to reproduce
signaled bug and verify their resolution, as well as specifications of new
features to implement.

The implemented end-to-end tests give more value to the software product because
verify the correctness of the main features of the application user interface,
and can be used as demonstration for the customer.

The implemented Continuous Integration solution increases the productivity of the
entire team, giving rapid feedbacks for every change introduced in the software,
and testing the application in a context similar to the production environment.

All the implemented solutions runs in a containerized infrastructure, so this
thesis demonstrates how working with this tools can be easy and productive.

The future developments regard the reorganization of the application to a
microservices architecture, that can be easily obtained thanks to the migration
to a container based infrastructure, and the extension of the implemented
Continuous Integration system to provide integration with git server specific
features, and better improve the productivity of the development team. 

A good part of this work is flexible and can be reused in the development of
other applications, so further developments are left to the imagination.
