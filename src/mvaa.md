# Containers and container based applications

In the past virtual machines covered a role of great importance in cloud
computing and virtualization, because of their attitude to provide standardized
and reproducible environments, installable everywhere. The main problem with
Virtual Machines is that their configuration concerns also with the detail of
the machine, such as hardware (ram, hard disk, processor, network interfaces,
etc.), when often those features don't require reproduction and introduce
overhead.  In fact, the most important part of the virtualization is the
operating system and application configuration, features that are reproduced
with fidelity by application containers. In addition, the only processes running
inside a container are the application ones, while inside a virtual machine the
processes of an entire operating system run, increasing significantly the
overhead.

The elimination of the overhead and complexity introduced by virtual machines is
not the only reason to prefer containers: *Docker* container engine provides
versioning of the images used for container creation, that is a great benefit
for software development, in fact versioning practices are adopted in all the
software development teams and software houses. Also Docker provides
component reuse: a base image can be reused by an infinite number of
applications, reducing impact on disk space and build times. Starting from
version 1.8, released on August 11, 2015, Docker provides image signing and
verification for improved security. @docker-content-trust

This chapter exposes the main features of *Docker* container engine and *Docker
Compose*, a container orchestration tool for defining and instancing
reproducible development environments. Once the reader is familiar with the main
features of Docker and Docker Compose, the container based structure of Gasista
Felice is explained in detail.

## Docker container engine

*Docker is an open-source project that automates the deployment of applications
inside software containers, by providing an additional layer of abstraction and
automation of operating-system-level virtualization on Linux, Mac OS and
Windows.* @wikipedia-docker

Docker permits to build images of applications that can be instanced as
containers. For any container, Docker provides an isolated and reproducible
environment with the advantage of accessing directly to the virtualization
features of Linux kernel, avoiding the overhead of installing and maintaining
virtual machines. To access the virtualization features, Docker can use
different interfaces such as *libcontainer*, *libvirt*, *LXC* (Linux Containers)
and *systemd-nspawn* @wikipedia-docker. Docker is written in the *Go*
programming language.

![Applications running in virtual machines](images/vm-diagram.eps)

![Applications running in Docker containers](images/docker-diagram.eps)

### Installation

Docker can be installed in Debian with:

    # apt-get install docker.io

Instructions for other GNU/Linux distributions can be found on Docker online
documentation. For Windows and Mac OS X, on August 11, 2015, *Docker Toolbox* has
been released as new installer replacing the older *Boot2Docker*. *The Docker
Toolbox is an installer to quickly and easily install and setup a Docker
environment on your computer. Available for both Windows and Mac, the Toolbox
installs Docker Client, Machine, Compose (Mac only), Kitematic and VirtualBox.
@docker-toolbox.* It's obvious that the only operating systems that can run
Docker natively (without the support of a virtual machine) are those that run
on Linux kernel.

### Docker images

The base for creating a Docker container is an image of an application. The main
repository of Docker images is *Docker Hub* @docker-hub, where images for all
the most famous open-source applications can be found. Any user can sign in to
Docker Hub and push an image, or make it build on the server. In order to create
an image, a *Dockerfile* with the specification of the environment has to be
written.

For example, this thesis is built using *LaTeX*, that is a powerful language for
document generation. Instead of installing LaTeX and all the required packages,
a prebuilt and ready to use image can be used to process LaTeX source code. With
Docker, compile this thesis in every supported operating system @docker-install
is just a matter of running this command on a shell:

	$ docker run -v $PWD:/code michelesr/latex /bin/bash pdflatex tesi.tex

This command will search for the `michelesr/latex` image in the system, and if
is not found, will pull the image from Docker Hub. Then the working directory,
that contains the LaTeX source files, will be mounted to `/code/` inside the
container, and will be used as working directory. At last, the command will run
and the thesis will be magically compiled even if LaTeX is not installed in the
system. The Dockerfile used to build the LaTeX image is the following:

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
in the filesystem root, setting `latex` as its owner. Finally it sets `latex` as
the default user and `/code/` as the default working directory.

The reason behind the running of the `latex` command as `latex` user is
correlated to the ownership of the files generated from LaTeX processing. Inside
the environment, the `latex` user has `1000` as UID (User Identifier) and GID
(Group Identifier), that are usually the default values for a desktop user in
Unix-like operating systems. This trick made the generated files directly
accessible from the host system user after the compilation. If for some reason
different UID or GID are required, they can be set in the Dockerfile modifying
the `adduser` instruction:

    RUN adduser latex --uid UID --gid GID --shell /bin/bash

Once a Dockerfile for the image has been defined, it can be reused in every
operating system running Docker, with the guarantee that the produced effects
are always the same (with the exception of kernel dependent behaviours).

### A layered approach

The Dockerfile for the previous image was built using `debian:8` image as base.
Instead of distributing an image as standalone, Docker use a smart layered
approach: for every instruction of the Dockerfile, it adds a layer to the base
image, then these layer are cataloged using a hash algorithm. The final image is
built overlapping all the layers, allowing the reuse of these to build other
images if necessary. For example, if the above Dockerfile user is modified, only
the layers after their modification are rebuilt. Also if another image that use
`debian:8` as base is built or pulled, the `debian:8` layers are reused. This
approach provides a significant boost of build speed and reduction of disk
usage.

### Running containers as daemons

Containers can be also used to run daemon applications, such as web servers. For
example, to run *Gogs*, a Git Service Application for the software versioning
written in *Go*, the command is:

    $ mkdir /var/gogs
    $ docker run -d -p 3000:3000 -v /var/gogs:/data codeskyblue/docker-gogs

As for the LaTeX image, a volume containing the application configuration files
is mounted, but also the `-d` parameter is used to inform Docker that the
software has to be launched as daemon, and `-p 3000:3000` is used to expose the
service outside the container. Once the daemon is up, the web application can be
visited at `http://localhost:3000`. The application log can be inspected:

    $ docker logs -f container_id

Container name or hash can be used as ID, and the `-f` parameter allows the
continuous prompt of new log entries.

### Running a shell inside a container

Sometimes is useful to run a shell inside the environment of a container. In
order to launch a bash shell inside a container the command is:

    $ docker run --rm -it image_id /bin/bash

Image name or hash can be used as ID. The `-i` stands for `--interactive`, and
the `-t` is used to allocate a virtual terminal device for the shell. The `--rm`
option is used to destroy the container after the exit of the shell. The
destruction can be safely performed because once a container is started (for
example as a daemon) with a command, will continue to execute that command until
its death.  Containers can be stopped, started and restarted, but once a
container is created, the command cannot be changed.

Even if the container is isolated and launching a command inside it can seems
meaningless, is useful when containers are linked in network. For example a
shell running inside a container that is linked to a database container can be
used to perform data manipulation or dump.

### Containers and images management

The default behaviour of Docker is to leave the stopped containers saved to
allow their restart, unless the `--rm` option is used. The running containers
can be listed with:

    $ docker ps

To list all the containers, including stopped ones, the `-a` parameter can be
used. To remove a stopped container:

    $ docker rm container_id [container2_id ...]

Container names or hashes can be used as ID. With the `-f` parameter, the
remotion of running containers can be forced. To remove all the stopped
containers in the system:

    $ docker rm $(docker ps -aq)

The `-q` parameter in the inner command lists the hashes of all the containers
in the system, then their hashes are used as container ID for their remotion
(running containers are ignored unless `-f` is provided). To lists the installed
images:

    $ docker images

To remove images:

    $ docker rmi image_id [image2_id ...]

As for the container, ID is the image name or hash. The `-f` option can be used
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

#### Image names and untagged images

Due to the layered approach used by Docker, an image is composed of more image
layers overlapped. When the `-a` parameter is added to `docker images`, even the
untagged images are shown. Untagged images haven't a name but are used as layer
of other images. Tagged images have the form of `repository:tag`, where:

- `repository` is the name of the image repository, found in the form
  `author/name` or `name` for official images (such as `debian`)

- `tag` distinguish between differents version of the image, and usually consist
  in a version number (`iojs:3`) or version name (`debian:jessie`) or `latest`
  for the latest version available (`michelesr/latex:latest`)

When tag is not specified during image building or pulling, `latest` is used.
Sometimes the same image is referred with more tags:

    $ docker images | grep iojs
    iojs   3         becb6285c124  5 days ago  634.8 MB
    iojs   latest    becb6285c124  5 days ago  634.8 MB

When a remotion of a image is requested with the `docker rmi` command and a
image name is provided as ID, Docker untags the image, removing the reference:

    $ docker rmi iojs:3
    Untagged: iojs:3

    $ docker images | grep iojs
    iojs   latest    becb6285c124  5 days ago  634.8 MB

Then if all the references for the image are removed and there aren't other images
that depends on it, the image is deleted from disk:

    $ docker rmi iojs:latest
    Untagged: iojs:latest
    Deleted: becb6285c1246f732efe6e90ac8931acab01be09031d97a4fc60e1b0b357309d
    Deleted: 2a153eb979fa93f1601fc89ab8ae301db02d7239d32286fc629e38a629c407b2
    Deleted: 79e9c6d779863a9df07ca0c5b59b18acc7d9e4c955547f37d5738e22cb63cbe7

Also the `2a153eb979fa` and `79e9c6d77986` images are deleted because they were
used only as layer for the `becb6285c124` image. An image that is used as a base
for other images cannot be removed, for example trying to remove the `debian:8`
image lead to the following result:

    $ docker images | grep debian
    debian    8    9a61b6b1315e    4 weeks ago    125.2 MB

    $ docker rmi -f debian:8
    Untagged: debian:8

    $ docker images -a | grep 9a61b6b1315e
    <none>    <none>    9a61b6b1315e    4 weeks ago    125.2 MB
   
    $ docker rmi -f 9a61b6b1315e
    Error response from daemon: Conflict, 9a61b6b1315e wasn't deleted
    Error: failed to remove images: [9a61b6b1315e]

The `9a61b6b1315e` cannot be removed because one or more images depends on it
(for example the `michelesr/latex` is built using `FROM debian:8`).  The
`debian:8` name and tag can be reassigned:

    $ docker tag 9a61b6b1315e debian:8

    $ docker images | grep debian
    debian    8    9a61b6b1315e    4 weeks ago    125.2 MB

### Containers linking

Docker use a VPN to allow communication between containers. To exploit
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

In the example above, `foobar` has been used as `--name` for the `nginx`
container that has been launched as a daemon. At the launch of the Debian
container, Docker links the container named `foobar`, registering an entry in
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
programming language.

### Installation

Docker Compose can be installed with *PIP*, the Python package manager:

    # pip2 install docker-compose

Python 3 is not supported. Docker Compose is only a wrapper to Docker functions,
and Docker has to be installed in the system. PIP can be installed in Debian
with the command:

    # apt-get install python-pip

Currently Docker Compose is not supported on Windows operating system. Install
instructions for other GNU/Linux distributions can be found on Docker Compose
online documentation. Docker Toolbox for Mac OS X includes Docker Compose.

### The docker-compose.yml configuration file

The `docker-compose.yml` configuration file Docker Compose contains a
description of the application containers to instantiate, link and run. The
syntax used by this configuration file is *YAML*, a language for
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
- `db`: the *PostgreSQL*  database management system

Docker Compose use a simple syntax to define ports exposing, volumes mounting,
and containers linking. All these functions are wrapped from Docker container
engine, so they work exactly as explained previously. In this example the `web`
component image is built from the Dockerfile, while the image for `db` is pulled
from Docker Hub image registry. To build and run the application:

    $ docker-compose up -d

The `-d` parameter is provided to detach the application process from the shell
in order to launch the application as daemon. The complete list of Docker
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

The `--rm` option is equal to the `--rm` option of `docker run` command.

## Gasista Felice architecture

Gasista Felice born as a *Python/Django* application with a *jQuery* based
interface. The evolution of technologies in web application clients and the
diffusion of the mobile devices leaded to the necessity of a new mobile responsive
web interface. Gasista Felice now provides a new interface based on *AngularJS*
framework by Google, and the old jQuery interface referred as *legacy* user
interface. *Nginx* web server is used as the application entry point. The role
of Nginx consists in:

- routing the requests through the application components
- managing buffering and queueing of the requests
- managing cryptography (https/tls)
- managing decompression of incoming requests and compression of responses
- caching the responses for reuse (disabled in development environments)

The routing of requests consists in the following rules:

- requests related to the new user interface are forwarded to *HarpJS* server
  using the http protocol

- requests related to the REST API or the old user interface are forwarded to
  *uWGSI* using the uwsgi protocol

HarpJS is a static file server with built-in preprocessing and its role
consist in serving HTML, CSS and Javascript files, that can be served directly
or converted on request from higher abstraction level languages such as:

- *Markdown*, *Jade* and *EJS* for HTML
- *Sass*, *Less*, *Stylus* for CSS
- *Coffescript* for Javascript

uWSGI is an application server and its role consists in:

- starting and managing Python/Django processes
- forwarding the requests to the processes
- serving static files for the legacy interface

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

For the `proxy` component, the configuration files are mounted from `./proxy` to
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
variables configuration. In order to start the Gasista Felice application:

    $ git clone https://github.com/befair/gasistafelice
    $ cd gasistafelice
    $ git checkout master-dj17
    $ make up

To insert test data inside the database:
    
    $ make dbtest
    
The application is visitable at `http://localhost:8080`. The used
images are hosted on Docker Hub. The Dockerfiles used for the images, as well as
the configuration files `site.conf` used for Nginx configuration,
`settings.env` and `Makefile` can be found in the Appendix. 
