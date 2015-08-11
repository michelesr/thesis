# Containers and container based applications

In the past Virtual Machines covered a role of great importance in cloud
computing and virtualization, because of their attitude to provide standardized
and reproducible environments, installable everywhere. The main problem with
Virtual Machines is that their configuration concerns also with the detail of
the machine, such as hardware (ram, hard disk, processor, network interfaces,
etc.), when often those feature don't require reproduction and introduce
overhead.  In fact, for a developer, the most important part of the
virtualization is the operating system and application configuration, features
that are reproduced with fidelity from containers.

The elimination of the overhead and complexity introduced by Virtual Machines is
not the only reason to prefer containers: *Docker* container engine provide
versioning of the container images, that is a great benefit for software
development, in fact versioning practices are adopted in all the software
development teams and software houses. Also Docker provide component reuses: a
base image can be reused by an infinite number of applications, reducing impact
on disk space and build times.

This chapter expose the main feature of *Docker* container engine and *Docker
Compose*, a container orchestration tool for defining reproducible development
environment. After the explanation of those tools, the structure and the
configuration of the development environment of Gasista Felice is explained in
detail.

## Docker container engine

*Docker is an open-source project that automates the deployment of applications
inside software containers, by providing an additional layer of abstraction and
automation of operating-system-level virtualization on Linux*@wikipedia-docker.

Docker permits to build images of applications that can be instanced as
containers. For any container, Docker provides an isolated and reproducible
environment with the advantage of accessing directly to the virtualization
feature of the Linux kernel, avoiding the overhead of installing and maintaining
virtual machines. To access the virtualization features, Docker can use
different interfaces such as *libcontainer*, *libvirt*, *LXC* (Linux Containers)
and *systemd-nspawn* @wikipedia-docker. Docker is written in the *Go*
programming language @wikipedia-go.

![Applications running in Virtual Machines](images/vm-diagram.eps)

![Applications running in Docker containers](images/docker-diagram.eps)

### Docker images

The base for creating a docker container is an image of an application. The main
repository of docker images is *Docker Hub* @docker-hub, where images for all the most
famous open-source applications can be found. Any user can sign to Docker Hub
and push an image, or make it build on the server. In order to create an image,
a *Dockerfile* with the specification of the environment has to be written.

For example, this thesis is built using *LaTeX*, that is a powerful language for
generating documents. Instead of installing the software to generate the
document from LaTeX sources, a prebuilt images with all the latex packages
necessary to compile the thesis can be used. With Docker, compile this thesis in
every supported operating system @docker-install is just a matter of running
this command on a shell:

	$ docker run -v $PWD:/code michelesr/latex /bin/bash pdflatex tesi.tex

This command will search for the `michelesr/latex` image in the system, and if
is not found, will pull the image from Docker Hub. Then the working directory,
that contains the LaTeX source files, will be mount to `/code` inside the
container, and will be used as working directory. At last, the command will run
and the thesis will be magically compiled even if LaTeX is not installed in the
system. The Dockerfile used to build the image is the following:

    FROM debian:8

    MAINTAINER Michele Sorcinelli "mikefender@cryptolab.net"

    ENV DEBIAN_FRONTEND         noninteractive

    RUN apt update && \
        apt install -y texlive-full && \
        rm -rf /var/lib/cache/apt/* \
               /var/lib/apt/lists/*

    RUN adduser latex --shell /bin/bash
    RUN mkdir /code/ && chown latex: -R /code/

    USER latex
    WORKDIR /code/

Starting from a *Debian* 8 image, it adds the environment variable
`DEBIAN_FRONTEND` and sets it to `nointeractive` to tell Debian that a non
interactive script is running, then runs `apt` to install the required packages
and `rm` to remove useless files from apt cache and lists. Once the required
packages are installed, it creates the `latex` user and the `/code/` directory
in the filesystem root, setting latex as its owner. Finally it sets `latex` as
the default user and `/code` as the default working directory.

The `latex` user is created in order to avoid using root for processing latex,
in fact if the root is used the created files (such as the produced document)
are owned by the root user, that is an unwanted behaviour.

### A layered approach

The Dockerfile for the previous image was built using `debian:8` image as base.
Instead of distributing an image as standalone, Docker use a smart layered
approach. For every instruction of the Dockerfile, it adds a layer to the base
image, then these layer are cataloged using a hash algorithm. The final image
is built overlapping all the layers, allowing the reuse of those to build other
images if necessary.

### Running containers as daemons 

Containers can also used to run daemon applications, such as web servers.  For
example, to run *Gogs*, a Git Service Application for the software versioning
written in *Go*, the command is:

    $ mkdir /var/gogs
    $ docker run -d -p 3000:3000 -v /var/gogs:/data codeskyblue/docker-gogs

As for the LaTeX image, a volume containing the application configuration files
is mounted, but also the `-d` parameter is used to inform Docker that the
software has to be launched as daemon, and `-p 3000:3000` is used to expose the
service outside the container. Once the daemon is up, the web application can be
visited at `http://localhost:3000`.

The application log can be inspected:

    $ docker logs -f container_id

Container name or hash can be used as id, and the `-f` parameter allow the
continuous prompt of new log entries.

### Running a shell inside a container

Sometimes is useful to run a shell inside the environment of a container. In
order to launch a bash shell inside a container the command is:

    $ docker run --rm -it image_id /bin/bash

Image name or hash can be used as id. The `-i` stands for `--interactive`, and
the `-t` is used to allocate a virtual terminal device for the shell. The `--rm`
option is used to destroy the container after the exit of the shell. The
destruction can be safely performed because once a container is started (for
example as a daemon) with a command, will continue to execute that command until
its death.  Containers can be stopped, started and restarted, but once a
container is created, the command cannot be changed.

Even if the container is isolated and launching a command inside it can seems
meaningless, is useful when containers are linked in network. For example with
can use a shell for a container that is linked to a database container to
perform a manual manipulation of the data.

### Containers and images management

The default behaviour of Docker is to leave the stopped container in memory to
allow their restart, unless the `--rm` option is used. The running containers
can be listed with:

    $ docker ps

To list all the containers, including stopped ones, the `-a` parameter can be
used. To remove a stopped container:

    $ docker rm container_id [container2_id ...]

Container names or hashes can be used as id. With the `-f` parameter, the
remotion of running containers can be forced. To remove all the container in
the system:

    $ docker rm -f $(docker ps -aq)

The `-q` option lists only the hash of the container, then these hashes are used
to remove the container in the outer command. The installed image can be listed
with:

    $ docker images

To remove images:

    $ docker rmi image_id [image2_id ...]

As for the container, id is the image name or hash. The `-f` option can be used
to remove an image even if containers for that image are instanced. The
directory used for storing of Docker data is `/var/lib/docker/`, and it
contains:

- images
- containers 
- metadata of images and containers
- temporary files

In particular, the `/var/lib/docker` directory can grow unexpectedly, completely
filling the machine disk. In order the exhaustion of the disk space, a periodic
cleaning of unused images, containers, and of the `/var/lib/docker/tmp`
directory has to be performed.

### Containers linking

Docker use a VPN to allow containers to communicate amongst them. To exploit
this feature, the `--link` parameter can be used to create a container that is
linked with one or more containers. For example:

    $ docker run -d --name foobar nginx
    d3dd23d4b9c688267ad04378a4cc8d71674732e73c5b6b388e7ff740e767c7af

    $ docker run --rm -it --link foobar:webserver debian /bin/bash
    root@59633390aff6:/# ping webserver -c 2
    PING webserver (172.17.1.210): 56 data bytes
    64 bytes from 172.17.1.210: icmp_seq=0 ttl=64 time=0.249 ms
    64 bytes from 172.17.1.210: icmp_seq=1 ttl=64 time=0.164 ms
    --- webserver ping statistics ---
    2 packets transmitted, 2 packets received, 0% packet loss
    round-trip min/avg/max/stddev = 0.164/0.207/0.249/0.043 ms

In the example above, `foobar` as been used as `--name` for the `nginx`
container that has been launched as a daemon. At the launch of the Debian
container, Docker links the container named `foobar`, and register an entry in
`/etc/hosts` with the hostname `webserver` referring to the `foobar` container.

    root@59633390aff6:/# cat /etc/hosts | grep webserver
    172.17.1.210    webserver d3dd23d4b9c6 foobar 

Containers linking is the base of serving container based web applications, that
usally are divided in different containers, such as:

- Database
- Application Server
- Proxy Server
- Web Interface
- Testing containers

To simplify the process of building, linking and managing a container based
application, *Docker Compose* can be used.

## Docker Compose

*Distributed applications consist of many small applications that work together.
Docker transforms these applications into individual containers that are linked
together. Instead of having to build, run and manage each individual container,
Docker Compose allows you to define your multi-container application with all of
its dependencies in a single file, then spin your application up in a single
command. Your application’s structure and configuration are held in a single
place, which makes spinning up applications simple and repeatable everywhere
@docker-compose.*

Docker Compose is a powerful tool for the development of container based
applications. With Docker Compose, the entire application structure can be
defined in a single configuration file called `docker-compose.yml`, and
instanced with a singe command. Docker compose is written in the *Python*
programming language @wikipedia-python.

### The docker-compose.yml configuration file

The `docker-compose.yml` configuration file Docker Compose contains a
description of the application containers to instantiate, link and run. The
syntax used by this configuration file is *YAML* @wikipedia-yaml, a language for
data serialization (like *JSON*).

An example of a simple web app configuration consists in a Dockerfile for the
application server and a `docker-compose.yml`:

    # ./Dockerfile

    WORKDIR /code
    ADD requirements.txt /code/
    RUN pip install -r requirements.txt
    ADD . /code
    CMD python app.py

    # ./docker-compose.yml

    web:
      build: .
      volumes: 
      - ./data:/data
      links:
      - db
      ports:
      - "8000:8000"
    db:
      image: postgres

This configuration is used to build an application that consists of two
containers:

- `web`: a Python web application server
- `db`: the *PostgreSQL* @wikipedia-psql database management system

Docker Compose use a simple syntax to define ports exposing, volumes mounting,
and containers links. All this function are wrapped from Docker container
engine, so they work exactly as explained previously. In this example the `web`
component image is built from the Dockerfile, while the image for `db` is pulled
from Docker Hub image registry. To build and run the application:

    $ docker-compose up -d

The `-d` parameter is provided to detach the application process from the shell
in order to launch the application in daemon mode. The complete list of Docker
Compose functions is:

      build              Build or rebuild services
      help               Get help on a command
      kill               Kill containers
      logs               View output from containers
      port               Print the public port for a port binding
      ps                 List containers
      pull               Pulls service images
      restart            Restart services
      rm                 Remove stopped containers
      run                Run a one-off command
      scale              Set number of containers for a service
      start              Start services
      stop               Stop services
      up                 Create and start containers
      migrate-to-labels  Recreate containers to add labels

In particular, the `logs` function is useful to prompt the logs from one or more
components:

    $ docker-compose logs web db 

The `run` function can be used to run a command inside an isolated container
that can be linked with the application ones, for example a postgres shell can be
launched from a container linked to `db` for data manipulation: 

	docker-compose run --rm web psql

The psql command has to be available inside the web container and can be
installed from Dockerfile adding:

    RUN apt-get install -y postgresql-client

With the same method, a bash shell can be launched inside a container:

    docker-compose run --rm web bash

The `--rm` options is equal to the same option in `docker run` command.

## Gasista Felice architecture

Gasista Felice born as a Python/Django application with a jQuery based
interface. The evolution of technologies in web application clients and the
diffusion of the mobile devices lead to the necessity of a new mobile responsive
web interface. Gasista Felice now provides a new interface based on AngularJS
framework by Google, and the old jQuery interface referred as legacy user
interface. *Nginx* web server is used as the application entry point. The role
of Nginx consists in:

- routing the requests to the application components

- managing cryptography (https/tls)

- managing decompression of requests and compression of responses

- caching the responses for reuse (disabled in development environments)

The routing of requests consists in the following rules:

- requests related to the new user interface are forwarded to HarpJS server
  using the http protocol

- requests related to the REST API or the old user interface are forwarded to
  uWGSI using the uwsgi protocol

HarpJS is a static file server with built-in preprocessing and its role
consist in serving HTML, CSS and Javascript files, that can be served directly
or converted on request from higher abstraction level languages such as:

- Markdown, Jade and EJS for HTML

- Sass, Less, Stylus for CSS

- Coffescript for Javascript

uWSGI is an application server and its role consists in:

- starting and managing Python/Django processes

- forward the requests to the processes

- serve static files for the legacy interface

![Requests routing for Gasista Felice application](images/gf-components.eps)

The containers for the Gasista Felice application are:

- `proxy`: Nginx container
- `back`: uWSGI, Python/Django container
- `front`: HarpJs container
- `db`: PostrgreSQL container

![Gasista Felice containers and their interaction](images/gf-containers.eps)

The `docker-compose.yml` used for the development of Gasista Felice is:

    proxy:
      image: befair/gasistafelice-proxy:latest
      volumes:
        - ./proxy:/etc/nginx/conf.d:ro
      ports:
        - '127.0.0.1:8080:80'
        - '127.0.0.1:8443:443'
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
      env_file: ./settings.env

    db:
      image: postgres:9.4
      env_file: ./settings.env

For the `proxy` component, configuration files are mounted from `./proxy` to
`/etc/nginx/conf.d` in read-only mode, the `80` (http) and `443` (https) ports are exposed in
the host `8080` and `8443` of the host machine, `front` and `back` containers
are linked in order to allow Nginx to connect to the application frontend and
backend.

For the `front` component, the directory containing the source code of the
AngularJS interface are mounted inside `/code/ui` in read-write mode to allow
their conversion by HarpJS.

For the `backend` component, source code and fixtures are mounted inside the
container, and the `7000` is exposed from uWSGI to enable direct http connection
for debug purposes. The backend is linked to `db` container to access database
features and the `settings.env` file is used for instancing environment
variables for application configuration.

For the `db` component, the `settings.env` file is used for environment
variables configuration.

The images used for Gasista Felice application can be found on Docker Hub with
related Dockerfiles, that are also published in Appendix. The `settings.env` and
`site.conf` for Nginx configuration can be found also on the Appendix.
