# End-to-end testing

End-to-end testing is the practice of testing the software from the user's point
of view. In a web application, an efficient approach to the end-to-end testing
is obtained with the implementation of browser automation scripts, that involve
the programmatic driving of one or different web browsers in order to access the
application as client and test the features provided by its user web interface.

End-to-end tests are not sufficient to ensure the quality of the software: in
order to offer a wider coverage of the software functionalities, unit tests and
integration tests have to be implemented as well, but end-to-end tests offer the
ability to discover bugs in user interface as well as bug in core components of
the application: if an operation provides an unexpected result for the user, or
triggers a server internal error, the causes of that behaviour have to be
researched in the related core components of the software. End-to-end testing
helps also to discover the bugs that are more visible to the final user, thus
the most important.

In addition to this, end-to-end tests can be used in Test Driven Development to
better define the specifications of the application. In fact, end-to-end
objective is to ensure that the application specifications are satisfied, and
can be used as a demonstration for the client that required functions are
implemented correctly.

While unit tests can be launched without additional configuration of the
software, end-to-end tests require a more complex configuration, and that
configuration will be discussed in detail in the next chapter. This chapter will
focus on the implementation of web automation based end-to-end tests with the
Protractor framework for the Gasista Felice AngularJS web application. The key
principles of AngularJS framework are explained in order to permit their
exploitation trough Protractor. In fact, the reason that lead to choosing
Protractor as framework are its integration with the constructs of AngularJS
framework.

## Gasista Felice end-to-end testing

Web automation scripts that make use of Protractor have to be written in the
Javascript programming language. In particular, the scripts used as
specifications for the end-to-end tests to perform should contain the following
constructs:

    describe('Name of application or component', function() {
        it('should have feature X', function () {
          // test code for feature X
          ...
        });
        it('should perform operation Y', function() {
          // test code for operation Y
          ...
        });
        ...
    });

The `describe()` function provided by Protractor framework can be used in order to
describe the entire application or one of its components. The prototype of
describe function is:

    describe(string, function)

The name of the application or component is used as first parameter, and an
anonymous function with the specification code is used as second parameter. The
content of the anonymous function is a sequence of `it()` functions that are
used to describe the test code for the features and operations of the
application or component. The `it()` prototype is:

    it(string, function)

A description of the feature or operation to test has to be provided as first
parameter, and an anonymous function with the implementation of the test is
provided as second parameter.

For Gasista Felice application, the `test/e2e/spec.js` script is used as
specification:

    describe('GF ng-app', function() {
        ...
    });

### Page title

The first step for Gasista Felice testing consists in assure that the
application is up, inspecting the web page title:

    it('should have a title', function() {
      browser.get('http://proxy:8080/');
      expect(browser.getTitle()).toEqual('Gasista Felice');
    });

In this snippet of code, the web browser performs a get request to
`http://proxy:8080` in order to access the home page of Gasista Felice, and
checks that the title is the expected. The `get()` method of the `browser`
object can be used to perform the request:

    browser.get(url);

In order to check the title, the `expect()` method is used. The method take as
input an object and returns another object with a `toEqual()` method that can be
called to ensure that the object provided as its input is equal to the object
provided as input for the `expect()` method:

    expect(object1).toEqual(object2);

This construct is used by the Protractor framework as assertion: the test fails
if the two object aren't equal.

### Login

The next step is performing the login action and ensure that the application
redirects to the user order page:

    it('should connect to the user order page', function() {

      // fill login form
      element(by.model('app.username')).sendKeys('01gas1');
      element(by.model('app.password')).sendKeys('des');

      // click on 'GO' button!
      $$('#go').click();

      // check current url
      expect(browser.getLocationAbsUrl())
        .toBe('/order/');

      // check user displayed name
      expect(element(by.binding('person.display_name')).getText())
        .toBe("Gasista_01 DelGas_01");
    });

The username and password field are retrieved from the page DOM by its model
name. Model is a feature provided by the AngularJS framework that permits the
two-way binding between a value of a DOM element and a object in the AngularJS
application scope. Two-way binding means that if the value of the object is
changed in the application scope the change is reflected in the DOM and
viceversa @two-way-binding. The definition of username and password elements for
Gasista Felice is:

    <input ng-model="app.username" id="username"
           type="text" class="validate">
    <input ng-model="app.password" id="password"
           type="password" class="validate">

The `ng-model` directive permits the binding of a DOM element to a property of
the AngularJS scope @ng-model. This is an example of how Protractor is designed to
work with AngularJS constructs. css selectors can be used as well but assuming
that the model of the username and password fields will never be changed, the
model name provides a more reliable reference to these elements. However,
sometimes the use of css selectors is the only way to select a DOM element, such
as for the `GO` button of Gasista Felice login page. The `$$(css_selector)` function is an
alias for:

    element(by.css(css_selector))

The `$$()` function is used to select an element of the DOM through a css
selector. In the code above the `GO` button is accessed using `#go` selector and
clicked through its `click()` method. The button definition is:

    <a ng-click="app.login()" href="#" id="go"
       class="waves-effect waves-blue-grey
              waves-grey-blue btn modal-action modal-close">
       GO
    </a>

The `#go` css selector refers to the id of the button, defined using `id="go"`.
One of the button classes could be used as well, but the id is preferable
(assuming that it's unique in the page context).

After the login, the `getLocationAbsUrl()` method of the `browser` object is
used to check that the current url match the one related to the orders page.

The `person.display_name` binding is used to refer the DOM element with the
function of displaying the name and verify that the value is the expected.
Binding is another feature of the AngularJS framework that permits the one-way
binding between the application scope and the DOM element. One-way binding means
that if the value of the object is changed in the application scope the change
is reflected in the DOM element, but a change in the DOM element doesn't reflect
in the application scope. In order to perform a one-way binding the `ng-bind`
@ng-bind or double curly brackets can be used:

    <p ng-bind="expression"></p>
    <p>{{expression}}</p>

The related DOM element definition is:

    <a ng-link="profile()" href=""
       title="Il mio profilo">
       {{ person.display_name }}
    </a>

### Order management

Once the user is logged and the browser is in the order page, the order
management is tested. The first action to perform is trying to increment and
decrement the quantity for a product and verify that the displayed quantity and
related total price is correct:

    it('should increment/decrement the price/qty when "+/-" are clicked',
       function () {
      // get the second item in the table
      var item = element.all(
                     by.repeater('product in order.pm.products')
                 ).get(1);

      // click 20 time on '+'
      for (var i=0; i < 20; i++)
        item.$$('.glyphicon-plus').click();

      // click 10 times on '-'
      for (var i=0; i < 10; i++)
        item.$$('.glyphicon-minus').click();

      // qty should be 10 units
      expect(item.element(by.model('product.quantity'))
        .getAttribute('value')).toBe('10');

      // price should be 250 euros
      expect(item.element(by.binding('product.quantity'))
        .getText()).toBe('€ 250,00');
    });

To retrieve the product from the list, the following construct is used:

    element.all(by.repeater(repeater)).get(index);

Repeater is another of the feature of the AngularJS framework. In particular,
the `ng-repeat` permits to generate DOM elements using an html template and an
array of objects. In Gasista Felice the list of products is generated using the
`ng-repeat` with `product in order.pm.products` as repeater, so the same
repeater can be used to retrieve the products in Protractor. In the code above
the second product is retrieved from the product list and the increment and
decrement buttons are retrieved using its css class. Even if there are more
buttons (a pair for every product) that share the same class, the right pair is
retrieved because the `$$()` is called as method of the `item` object.

Product quantity and price using model selector and binding selector,
respectively, and again, the methods are called from the `item` object to
exclude other products. A particular attention have to be paid at this
instruction:

      expect(item.element(by.binding('product.quantity'))
        .getText()).toBe('€ 250,00');

The `product.quantity` binding is used. The relation between the used binding
and the total price of the product has to be researched from its DOM element
definition:

    <td data-title="total" class="tdprod" >
      {{product.quantity*product.price | currency:"€"}}
    </td>

AngularJS framework permits to perform operations in the template, in this case
the total price is calculated as product between unitary price and quantity. In
a *MVC* (Model View Controller) software architecture, the business logic should
be separated from the view, and putting operation in the template violates this
principle. This is an example of how writing tests can lead to the discovery of
bad code design choices.

Other implemented order management tests are:

    it('should never decrement the price/qty under 0',
    function () {
      var item = element.all(
                     by.repeater('product in order.pm.products')
                 ).get(1);

      for (var i=0; i < 20; i++)
        item.$$('.glyphicon-minus').click();

      expect(item.element(by.model('product.quantity'))
        .getAttribute('value')).toBe('0');

      expect(item.element(by.binding('product.quantity'))
        .getText()).toBe('€ 0,00');
    });

The meaning is obvious.
