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
configuration will be discussed in detail in the next chapter.

This chapter will focus on the implementation of web automation based end-to-end
tests with the Protractor framework for the Gasista Felice AngularJS web
application. The key principles of AngularJS framework are explained in order to
permit their exploitation trough Protractor. In fact, the reason that lead to
choosing Protractor as framework are its integration with the constructs of
AngularJS framework. At last, will be showed how to repeat the same test
routines more times with different parameters, and how a mobile responsive
interface can be tested with different window sizes.

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

### Connection to the application

The first step for Gasista Felice testing consists in assure that the
application is up, inspecting the web page title:

    it('should have a title', function() {
      browser.get('http://proxy:8080/');
      expect(browser.getTitle())
        .toEqual('Gasista Felice');
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
      element(by.model('app.username'))
        .sendKeys('01gas1');
      element(by.model('app.password'))
        .sendKeys('des');

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
        .getAttribute('value'))
          .toBe('10');

      // price should be 250 euros
      expect(item.element(by.binding('product.quantity'))
        .getText())
          .toBe('€ 250,00');
    });

To retrieve the product from the list, the following construct is used:

    element.all(by.repeater(repeater)).get(index);

Repeater is another of the feature of the AngularJS framework. In particular,
the `ng-repeat` permits to generate DOM elements using an html template and an
array of objects @ng-repeat. In Gasista Felice the list of products is generated
using the `ng-repeat` with `product in order.pm.products` as repeater, so the
same repeater can be used to retrieve the products in Protractor. In the code
above the second product is retrieved from the product list and the increment
and decrement buttons are retrieved using its css class. Even if there are more
buttons (a pair for every product) that share the same class, the right pair is
retrieved because the `$$()` is called as method of the `item` object. The
button are clicked multiple times using loops.

Product quantity and price using model selector and binding selector,
respectively, and again, the methods are called from the `item` object to
exclude other products. A particular attention have to be paid at this
instruction:

      expect(item.element(by.binding('product.quantity'))
        .getText())
          .toBe('€ 250,00');

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

Another check to perform is that the quantity for a product should never go
under zero:

    it('should never decrement the price/qty under 0',
    function () {
      var item = element.all(
                   by.repeater('product in order.pm.products')
                 ).get(1);

      for (var i=0; i < 20; i++)
        item.$$('.glyphicon-minus').click();

      expect(item.element(by.model('product.quantity'))
        .getAttribute('value'))
          .toBe('0');

      expect(item.element(by.binding('product.quantity'))
        .getText())
          .toBe('€ 0,00');
    });

The second product is retrieved from the list, the decrement button pressed 20 times and
the quantity value checked.

### Insertion and check of products in the basket

In order to check the insertion of the products in the basket, the following
test is used:

    it('should add a product to the basket', 
       function() {

      var item = element.all(
                    by.repeater('product in order.pm.products')
                 ).get(2);

      // set the quantity to 3
      item.element(by.model('product.quantity'))
        .clear();
      item.element(by.model('product.quantity'))
        .sendKeys('3');

      // add to the basket
      element(by.buttonText('Aggiungi al paniere')).click();

      // handle the alert popup
      handleAlertPopup();

      // go to the basket
      browser.setLocation('basket');

      // get the first order
      item = element.all(
               by.repeater('item in basket.open_ordered_products')
             ).get(0);

      // get all the column from the first order
      var columns = item.$$('td');

      // expects to have 8 columns (counting the hidden ones)
      expect(columns.count())
        .toBe(8);

      // check the fields
      expect(columns.get(0).getText())
        .toBe('Ord. 59');
      expect(columns.get(1).getText())
        .toBe('Fornitore 01');
      expect(columns.get(2).getText())
        .toBe('Scarpe Uomo (paio)');
      expect(columns.get(3).getText())
        .toBe('€ 20,00');
      expect(item.element(by.model('item.quantity'))
        .getAttribute('value'))
          .toBe('3');
      expect(columns.get(6).getText())
        .toBe('€ 60,00');
    });

The third product is retrieved from list, then its quantity field is cleared and
set to 3, then the `Aggiungi al paniere` button is retrieved from its text and
clicked to add the product to the basket, and the resulting alert is managed
with the `handleAlertPopup()` function:

    var handleAlertPopup = function() {
      var EC = protractor.ExpectedConditions;
      browser.wait(EC.alertIsPresent(), 5000);
      browser.switchTo().alert().accept();
    };
    
Then the location is set to the basket page, the list of the ordered products
its retrieved and for the first item in the list the fields are counted and
checked.

### Test parametrization and mobile responsive applications

Gasista Felice is a mobile responsive application, so the implemented tests
have to be applied two times with different window dimensions.

In order to repeat two times the tests the `map()` method of `Array` objects can
be exploited. *The map() method creates a new array with the results of calling a
provided function on every element in this array* @mdn-map. With the `map()`
method an array of index can be created and these index are used as parameter
for the execution of test routines:

    [0,1].map(function(index) {

      it('should have a title', function() {
        if (!index)
          browser.driver.manage().window().maximize();
        else
          browser.driver.manage().window().setSize(768, 1024);
        browser.get('http://proxy:8080/');
        expect(browser.getTitle()).toEqual('Gasista Felice');
      });

      ...
    });

In this way the routines are performed two times, the first time with a
maximized window (the size of the maximized window depends on the desktop
resolution used in the operating system that runs the browser), the second time
with a fixed size that triggers the mobile interface. The `index` variable can
always be checked in order to determine the current interface. More index can be
used in order to repeat the tests with different window sizes.

The main difference between the Gasista Felice desktop and mobile
interface is that the second make use of a navigation bar that display user
related informations and logout and settings buttons, while in the desktop
interface these elements are always showed. This navigation bar can be showed
and hided with the click of its toggle button.

Button toggle can be implemented with simple if-else instructions:

    ...

    it('should connect to the user order page', function() {
      ...

      // check user displayed name
      if (index) {
        $$('.navbar-toggle').click();
        expect(element(by.binding('person.display_name')).getText())
          .toBe("Gasista_01 DelGas_01");
        $$('.navbar-toggle').click();
      }
      else
        expect(element(by.binding('person.display_name')).getText())
          .toBe("Gasista_03 DelGas_01");
    });

    ...

The button for showing and hiding the navigation bar is retrieved from its css
class and clicked twice (first time to show, second time to hide again).

#### Logout

Because with the use of `map()` the login routine is performed twice, a logout
routine has to be appended to the bottom of test specifications:

    it('should logout', function() {
      if(index)
        $$('.navbar-toggle').click();
      $$('#btn-logout').click();
    });
