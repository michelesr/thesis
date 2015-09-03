# Source Code

In this appendix are showed the most relevant source code files:

- Dockerfiles
- Docker Compose files
- End-to-end Javascript files
- Makefile
- Bash functions for the CI system

The source code of Gasista Felice project, including the backend and frontend is
available in `master-dj17` branch of the `befair/gasistafelice` GitHub
repository: `https://github.com/befair/gasistafelice/`. The code is updated at
this revision:

    commit ff02193cee44a03772595450faf419b5f7cdbdb8
    Merge: 8e59faf 6cdf4df
    Author: Luca Ferroni <luca@befair.it>
    Date:   Thu Sep 3 12:09:40 2015 +0200

        Merge pull request #151 from michelesr/dev

        E2E: improved test/e2e/spec.js

## Dockerfiles

#### Gasista Felice application server

    FROM kobe25/uwsgi-python2:latest

    MAINTAINER Antonio Esposito "kobe@befair.it"

    ENV LC_ALL                  it_IT.UTF-8
    ENV LANG                    it_IT.UTF-8
    ENV LANGUAGE                it_IT.UTF-8

    # the following ENV directives have been reformatted
    # for printing purposes, the correct syntax is
    # "ENV VAR_NAME value", in one line

    ENV PYTHONPATH
        /code:/code/gasistafelice:/usr/local/lib/python2.7/site-packages
    ENV UWSGI_CHDIR
        /code/gasistafelice
    ENV UWSGI_WSGI_FILE
        /code/gasistafelice/gf/wsgi.py
    ENV DJANGO_SETTINGS_MODULE
        gf.settings
    ENV UWSGI_STATIC_MAP
        /static=/code/gasistafelice/static
    ENV UWSGI_STATIC_SAFE
        /usr/local/lib/python2.7/site-packages/django/contrib/admin/static/admin

    COPY deps/debian /code/gasistafelice/deps/debian
    RUN apt update && \
        apt install -y $(cat /code/gasistafelice/deps/debian) && \
        rm -rf /var/lib/apt/lists/*

    COPY deps/locale.gen /etc/locale.gen
    RUN locale-gen

    COPY deps/ /code/gasistafelice/deps/
    RUN pip install -r /code/gasistafelice/deps/dev.txt

    COPY ./ /code/gasistafelice/
    WORKDIR /code/gasistafelice/

The Dockerfile for `kobe25/uwsgi-python2:latest` is:

    FROM python:2.7.7

    MAINTAINER Antonio Esposito "kobe@befair.it"

    ENV DEBIAN_FRONTEND noninteractive
    ENV PYTHONUNBUFFERED 1
    ENV PYTHONPATH /code:/usr/local/lib/python2.7/site-packages
    ENV UWSGI_CALLABLE app
    ENV UWSGI_PYTHON_AUTORELOAD 1 #
    ENV UWSGI_PY_TRACEBACKER
    ENV UWSGI_MASTER true
    ENV UWSGI_MASTER_AS_ROOT true
    ENV UWSGI_UID app
    ENV UWSGI_GID app
    ENV UWSGI_UWSGI_SOCKET 0.0.0.0:5000
    ENV UWSGI_NO_ORPHANS true
    ENV UWSGI_VACUUM true
    ENV UWSGI_LOG_DATE true
    ENV UWSGI_LAZY_APPS false
    ENV UWSGI_WORKERS 2
    ENV UWSGI_THREADS 1
    ENV UWSGI_ENABLE_THREADS true
    ENV UWSGI_BUFFER_SIZE 65536
    ENV UWSGI_MAX_REQUESTS 128
    ENV UWSGI_HARAKIRI 120
    ENV UWSGI_HARAKIRI_VERBOSE true
    ENV UWSGI_THUNDER_LOCK true
    ENV PGDATABASE app
    ENV PGUSER app
    ENV PGPASSWORD app
    ENV PGHOST db
    ENV PGPORT 5432

    RUN groupadd -r app && \
        useradd -r -g app -d /code app
    RUN apt update && \
        apt install -y \
          build-essential \
          python-dev \
          python-setuptools && \
        rm -rf /var/lib/apt/lists/*
    RUN pip install \
          'uWSGI >=2.0, <2.1'
    EXPOSE 5000 CMD ["uwsgi"]

#### Gasista Felice proxy server

    FROM kobe25/nginx:latest

    MAINTAINER Antonio Esposito "kobe@befair.it"

    COPY site.conf /etc/nginx/conf.d/site.conf

The `site.conf` file is:

    server {
      listen 8080 default_server;
      #listen 8443 ssl spdy default_server;

      server_name _;
      root /code;

      charset utf-8;
      client_max_body_size 75M;
      client_body_timeout 600s;
      #keepalive_timeout 5;

      location = /favicon.ico {
        log_not_found off;
        access_log off;
      }

      location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
      }

      location ~ /\. {
        deny all;
        log_not_found off;
        access_log off;
      }

      location = / {
        proxy_pass      http://front:5000/ui/index.html;
        expires max;
      }

      location /components/ {
        proxy_pass      http://front:5000/ui/components/;
        expires max;
      }

      location /ui/bower_components/ {
        proxy_pass      http://front:5000/libs/bower_components/;
        expires max;
      }

      location /ui/ {
        proxy_pass      http://front:5000;
        expires max;
      }

      location /static/ {
        include          uwsgi_params;
        uwsgi_pass       uwsgi://back:5000;
        expires max;
      }

      location /media/ {
        include          uwsgi_params;
        uwsgi_pass       uwsgi://back:5000;
      }

      location /api/ {
        gzip             on;
        gzip_types       application/json;
        gzip_min_length  1000;

        include          uwsgi_params;
        uwsgi_pass       uwsgi://back:5000;
      }

      location /gasistafelice/ {
        include          uwsgi_params;
        uwsgi_pass       uwsgi://back:5000;
      }

      location / {
        return 404;
      }
    }

The Dockerfile for `kobe25/nginx:latest` is:

    FROM nginx:1.9

    MAINTAINER Antonio Esposito "kobe@befair.it"

    RUN rm -rf /etc/nginx/conf.d/*

    COPY nginx.conf /etc/nginx/nginx.conf

#### Gasista Felice frontend server

    FROM iojs:2.5

    MAINTAINER Antonio Esposito "kobe@befair.it"

    RUN npm config set registry http://registry.npmjs.org/

    COPY deps/npm /code/ui/deps/npm
    RUN npm install -g $(cat /code/ui/deps/npm)

    COPY ./bower.json /code/libs/bower.json
    RUN cd /code/libs/ && bower install --allow-root

    EXPOSE 5000

    COPY ./ /code/ui/
    WORKDIR /code/ui/

    CMD ["harp", "server", "-i", "0.0.0.0", "-p", "5000", "/code"]

#### End-to-end test framework

    FROM michelesr/protractor:latest

    MAINTAINER Michele Sorcinelli "mikefender@cryptolab.net"

    COPY . /code

The Dockerfile for `michelesr/protractor:latest` is:

    FROM iojs:3

    MAINTAINER Michele Sorcinelli "mikefender@cryptolab.net"

    RUN npm install -g protractor

    RUN mkdir /code

    WORKDIR /code

    CMD ["protractor", "conf.js"]

#### Jenkins Dockerfile

    FROM jenkins:latest

    MAINTAINER Michele Sorcinelli "mikefender@cryptolab.net"

    USER root
    RUN apt-get update \
          && apt-get install -y python python-pip sudo \
          && rm -rf /var/lib/apt/lists/*
    RUN pip install 'docker-compose==1.4'
    RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

    USER jenkins
    COPY plugins.txt /usr/share/jenkins/plugins.txt
    RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

The `plugins.txt` file is:

    scm-api:latest
    git-client:latest
    git:latest
    greenballs:latest

## Docker Compose files

#### Gasista Felice

    proxy:
      image: befair/gasistafelice-proxy:latest
      volumes:
        - ./proxy/site.conf.dev:/etc/nginx/conf.d/site.conf:ro
      ports:
        - '127.0.0.1:8080:8080'
        - '127.0.0.1:8443:8443'
      links:
        - front
        - back

    front:
      image: befair/gasistafelice-front:latest
      volumes:
        - ./ui:/code/ui:rw

    back:
      image: befair/gasistafelice-back:latest
      volumes:
        - ./gasistafelice:/code/gasistafelice:ro
        - ./gasistafelice/fixtures:/code/gasistafelice/fixtures:rw
        - /tmp/gf_tracebacker:/tmp/tracebacker:rw
        - /tmp/gf_profiling:/tmp/profiling:rw
      ports:
        - '127.0.0.1:7000:7000'
      links:
        - db
      env_file: ./compose/settings.env

    db:
      image: postgres:9.4
      env_file: ./compose/settings.env

The `compose/settings.env` file is:

    APP_ENV=dev
    POSTGRES_USER=app
    POSTGRES_PASSWORD=app
    UWSGI_UID=root
    UWSGI_GID=root
    UWSGI_HTTP=0.0.0.0:7000
    UWSGI_WORKERS=1
    UWSGI_PY_TRACEBACKER=/tmp/tracebacker

#### Testing

    hub:
      image: selenium/hub:latest

    firefox:
      image: selenium/node-firefox-debug:latest
      links:
        - hub
        - proxy
      ports:
        - '127.0.0.1:5900:5900'
      env_file:
        - ./test/e2e/settings.env

    chrome:
      image: selenium/node-chrome-debug:latest
      links:
        - hub
        - proxy
      ports:
        - '127.0.0.1:5901:5900'
      env_file:
        - ./test/e2e/settings.env

    e2e:
      image: michelesr/protractor:latest
      volumes:
        - ./test/e2e:/code:ro
      links:
        - hub

The `test/e2e/settings.env` file is:

    SCREEN_WIDTH=1920
    SCREEN_HEIGHT=1080

#### CI

    proxy:
      build: ./proxy
      ports:
        - '127.0.0.1:8080:8080'
        - '127.0.0.1:8443:8443'
      links:
        - front
        - back

    front:
      build: ./ui

    back:
      build: ./gasistafelice
      links:
        - db
      env_file: ./compose/settings_ci.env

    db:
      image: postgres:9.4
      env_file: ./compose/settings_ci.env

    hub:
      image: selenium/hub:latest

    e2e:
      build: ./test/e2e
      links:
        - hub

    firefox:
      image: selenium/node-firefox-debug:latest
      links:
        - hub
        - proxy
      env_file:
        - ./test/e2e/settings.env

    chrome:
      image: selenium/node-chrome-debug:latest
      links:
        - hub
        - proxy
      env_file:
        - ./test/e2e/settings.env

The `compose/settings_ci.env` file is:

    APP_ENV=prod
    POSTGRES_USER=app
    POSTGRES_PASSWORD=app

## End-to-end Javascript files

#### Protractor configuration file

    // conf.js
    exports.config = {
      seleniumAddress: 'http://hub:4444/wd/hub',
      specs: ['spec.js'],
      multiCapabilities: [
        { browserName: "firefox" },
        { browserName: "chrome" }
      ]
    }

#### Test routine specification file

    var handleAlertPopup = function() {
      var EC = protractor.ExpectedConditions;
      browser.wait(EC.alertIsPresent(), 5000);
      browser.switchTo().alert().accept();
    };

    describe('GF ng-app', function() {

      [0,1].map(function(index) {

        it('should have a title', function() {
          if (!index)
            browser.driver.manage().window().maximize();
          else
            browser.driver.manage().window().setSize(768, 1024);
          browser.get('http://proxy:8080/');
          expect(browser.getTitle()).toEqual('Gasista Felice');
        });

        it('should connect to the user order page', function() {
          // fill login form
          element(by.model('app.username')).sendKeys('01gas1');
          element(by.model('app.password')).sendKeys('des');

          // click on 'GO' button!
          // $$(selector) = element(by.css(selector))
          $$('#go').click();

          // check current url
          expect(browser.getLocationAbsUrl())
            .toBe('/order/');

          // check user displayed name
          if (index) {
            $$('.navbar-toggle').click();
            expect(element(by.binding('person.display_name')).getText())
              .toBe("Gasista_01 DelGas_01");
            $$('.navbar-toggle').click();
          }
          else
            expect(element(by.binding('person.display_name')).getText())
              .toBe("Gasista_01 DelGas_01");
        });

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

          // qty should be 10
          expect(item.element(by.model('product.quantity'))
            .getAttribute('value'))
              .toBe('10');

          // price should be 250 euros
          expect(item.element(by.binding('product.quantity'))
            .getText())
              .toBe('€ 250,00');
        });

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

        it('should add a product to the basket', function() {
          var item = element.all(
                       by.repeater('product in order.pm.products')
                     ).get(2);

          // set the quantity to 3
          item.element(by.model('product.quantity')).clear();
          item.element(by.model('product.quantity')).sendKeys('3');

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
          expect(columns.get(0)
            .getText())
              .toBe('Ord. 59');
          expect(columns.get(1)
            .getText())
              .toBe('Fornitore 01');
          expect(columns.get(2)
            .getText())
              .toBe('Scarpe Uomo (paio)');
          expect(columns.get(3)
            .getText())
              .toBe('€ 20,00');
          expect(item.element(by.model('item.quantity'))
            .getAttribute('value'))
              .toBe('3');
          expect(columns.get(6)
            .getText())
              .toBe('€ 60,00');
        });

        it('should logout', function() {
          if(index)
            $$('.navbar-toggle').click();
          $$('#btn-logout').click();
        });
      });
    });

## Makefile

    help:
        @echo 'make            Print this help'
        @echo
        @echo 'Whole app commands:'
        @echo 'make up         Download and start all'
        @echo 'make ps         Container status'
        @echo 'make logs       See all logs'
        @echo 'make stop       Stop all containers'
        @echo 'make restart    Restart all containers'
        @echo 'make rm         Delete containers'
        @echo 'make test       Run all tests'
        @echo
        @echo 'Container commands:'
        @echo 'make logs-back  See only backend logs'
        @echo 'make back       Debug in backend via iPython'

    test-cat.yml: docker-compose.yml compose/test.yml Makefile
        @cat docker-compose.yml compose/test.yml > test-cat.yml

    clean:
        @rm test-cat.yml

    up:
        @docker-compose up -d
        @docker-compose ps

    logs log:
        @docker-compose logs

    logs-back log-back:
        @docker-compose logs back

    start:
        @docker-compose start
        @docker-compose ps

    stop: test-cat.yml
        @docker-compose -f test-cat.yml stop
        @docker-compose ps

    restart:
        @docker-compose restart
        @docker-compose ps

    ps:
        @docker-compose ps

    t:
        @docker-compose run --rm test /bin/bash

    front fe frontend ui:
        @docker-compose run --rm front /bin/bash

    back be backend api:
        @docker-compose run --rm back /bin/bash

    shell:
        @docker-compose run --rm back django-admin shell

    dbshell:
        @docker-compose run --rm back django-admin dbshell

    dbinit:
        @docker-compose run --rm back django-admin makemigrations --noinput
        @docker-compose run --rm back django-admin migrate
        @docker-compose run --rm back django-admin init_superuser

    dbtest: dbclean
        @docker-compose run --rm back psql \
        -f /code/gasistafelice/fixtures/test.sql

    dbdump:
        @docker-compose run --rm back pg_dump \
        -f /code/gasistafelice/fixtures/test.sql app

    dbclean:
        @docker-compose run --rm back dropdb app
        @docker-compose run --rm back createdb app -O app

    rm: stop
        @docker-compose -f test-cat.yml rm -v -f

    rmall: rm
        @docker rmi -f befair/gasistafelice-{front,back}

    rmc:
        @docker rm -f $(docker ps -aq)

    rmi: rmc
        @docker rmi -f $(docker images -aq)

    test: test-info test-unit test-integration test-e2e
        @echo 'All tests passed!'

    test-info:
        @echo 'To prepare the test db (this will clear your data):'
        @echo '    $$ make dbtest'
        @echo

    test-unit:
        @echo 'Unit test: not implemented yet'

    test-integration:
        @echo 'Integration test: not implemented yet'

    test-e2e: test-cat.yml
        @echo 'End-to-end test: running protractor'
        @docker-compose -f test-cat.yml up -d
        @sleep 5
        @docker-compose -f test-cat.yml run --rm e2e

## Bash functions for the CI system

    gogs() {
      docker run --name gogs -d \
                 -p 3000:3000 \
                 -p 32:22 \
                 -p 5000:8080 \
                 -v $HOME/gogs_data:/data \
                 gogs/gogs
    }

    jenkins() {
      docker run --name jenkins -d \
             -v /var/run/docker.sock:/var/run/docker.sock \
             -v /usr/lib/libdevmapper.so.1.02:/usr/lib/libdevmapper.so.1.02 \
             -v $(which docker):/usr/bin/docker \
             -v $HOME/jenkins_data:/var/jenkins_home \
             --net container:gogs \
             michelesr/jenkins
    }


    postfix() {
      docker run --name postfix -d \
             -e MAILNAME='micheles.no-ip.org' \
             -e MYNETWORKS='127.0.0.1' \
             --net container:gogs \
             panubo/postfix
    }
