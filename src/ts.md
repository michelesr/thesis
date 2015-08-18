# Setup of the test environment

In the previous chapter the Protractor framework has been used in order to implement
browser automation based end-to-end tests for the AngularJS web interface of
Gasista Felice application. In this chapter the software used to run Protractor
based test is discussed and in particular its container based structure and
interaction with the web application. Assuming that the developer is already
using Docker and Docker Compose to run the container based application, the
container structure is extended in order to include the testing containers and
to permit the running of the end-to-end tests without the duty of manual
installation and configuration of the testing framework relapsing on the
developer.

## Protractor

Protractor is not available yet as official Docker image. For the purpose of
running end-to-end tests for Gasista Felice and other AngularJS web
Applications, a Protractor image has been builded and pushed to the Docker Hub.
The image is called `michelesr/protractor`, and this is the Dockerfile used for
the build:

    FROM iojs:2.4

    MAINTAINER Michele Sorcinelli "mikefender@cryptolab.net"

    RUN npm install -g protractor

    RUN mkdir /code

    WORKDIR /code

    CMD ["protractor", "conf.js"]

Protractor is a *Node.js* application. Node.js is a cross-platform runtime
environment for server-side and networking Javascript applications. In order to
run Protractor, a *Io.js* image as been used as base. Io.js is a fork of the
Node.js open-source project, created for the primary purpose of moving the
Node.js project to a structure where the contributors and community can step in
and effectively solve the problems facing Node (including the lack of active and
new contributors and the lack of releases) @node-to-iojs . From the `iojs:2.4`
base image, Protractor framework is installed using `nmp` (Node Package
Manager), a `/code/` directory is created and used as working directory, and the
`protractor conf.js` command is used as default command for running the
framework.

The `conf.js` configuration file is the entry point of Protractor:

    // conf.js
    exports.config = {
      seleniumAddress: 'http://hub:4444/wd/hub',
      specs: ['spec.js'],
      multiCapabilities: [
        { browserName: "firefox" },
        { browserName: "chrome" }
      ]
    }

The `exports.config` object is used to define the configuration of the
Protractor framework, that includes:

- a list of specification files used to run the end-to-end tests
- a list of the browsers used as clients for the web application
- the network address of the *Selenium* server

## Selenium
