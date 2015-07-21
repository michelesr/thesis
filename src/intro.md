# Introduction 

## Organization of this document

Chapter 2 will expose the technological context that lead to the work done in the thesis project, and the economical social context of team which I collaborated.

Chapter 3 exhibits the main typologies of automatic tests with related examples, starting from unit tests, going through integration tests and finally introducing the end to end tests.

Chapter 4 talks about how Docker container engine and *Docker Compose* @docker-compose can be used to easily reproduce an environment similar to the one deployed in production in order to make developers life better, and the main advantages of this approach compared to the use of *Vagrant* @vagrant. This chapter will also expose the motivation that leads to the choice of this instruments and will show the architecture of the software that will be tested.

Chapter 5 shows the main tools used in end to end tests and how to configure the testing framework to work with the container ecosystem. The configuration is an integral part of this thesis and aims to reduce the developer effort to get the testing environment.

Chapter 6 will cover the end to end test techniques used for ensure a better quality of the tested software. In particularly *AngularJS* @angularjs applications will be tested using *Protractor* @protractor testing framework. Testing often reveals bad design choice made during the development process, so this chapter will also give some advice to how to write a better software and better tests.

Chapter 7 will explain how to build a Continuous Integration system to provide automatic run of tests once the code is updated and pushed into the project repository. Continuous integration is essential if we talk about continuous delivery and rolling release of the software products.
