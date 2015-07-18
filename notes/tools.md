# Tools

## Karma

Karma is a unit-test runner used to launch unit-test in angular applications. It uses a browser (such as firefox or chrome) to test the javascript code in the web application.

## Protractor

Protractor is end-to-end test runner for angular applications. It uses selenium server and webdrivers to launch e2e test.

## Jasmine

Jasmine is a Behavior Driven Development testing framework for JavaScript. It does not rely on browsers, DOM, or any JavaScript framework. Thus it's suited for websites, Node.js projects, or anywhere that JavaScript can run.

# Tips 

When writing unit tests use mock objects to replace feature not avaliable in the test environment, for example the web server (in angular replace $http with $httpBackend that is a mock object that can be instructed to return always the same thing from the get request). 
