# Modern web applications architecture

## Docker container engine

*Docker* is an open-source project that automates the deployment of applications
inside software containers, by providing an additional layer of abstraction and
automation of operating-system-level virtualization on Linux @wikipedia-docker.
Docker permits to build images of applications that can be instanced as
containers. For any container, Docker provides an isolated and reproducible
environment with the advantage of accessing directly to the virtualization
feature of the Linux kernel , avoiding the overhead of installing and
maintaining virtual machines. To access the virtualization features, Docker can
use different interfaces such as *libcontainer*, *libvirt*, *LXC* (Linux
Containers) and *systemd-nspawn* @wikipedia-docker.

![Applications running in Virtual Machines](images/vm-diagram.eps)

![Applications running in Docker containers](images/docker-diagram.eps)

### Docker images

The base for creating a docker container is an image of an application. The main
repository of docker images is *Docker Hub*, where images for all the most
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
and the thesis will be magically compiled even if LaTeX is not installed in your
system. The Dockerfile used to build the image is the following:

    FROM debian:8
    
    MAINTAINER Michele Sorcinelli "mikefender@cryptolab.net"
    
    ENV DEBIAN_FRONTEND         noninteractive
    
    RUN apt update && \
        apt install -y texlive-full && \
        rm -rf /var/lib/cache/apt/* \
               /var/lib/apt/lists/*
    
    RUN mkdir /code
    
    WORKDIR /code

Starting from a *Debian* 8 image, it adds the environment variable
`DEBIAN_FRONTEND` and sets it to `nointeractive` to tell Debian that the shell
is not interactive, then runs `apt` to install the required packages and `rm` to
remove useless files from apt cache and lists, finally it creates the `/code`
directory and sets it as the working directory.    

### A layered approach

The Dockerfile for the previous image was built using `debian:8` image as base.
Instead of distributing an image as standalone, Docker use a smart layered
approach. For every instruction of the Dockerfile, it adds a layer to the base
image, then these layer are named using a hash algorithm. The final image is
built overlapping all the layers, allowing the reuse of those to build other
images if necessary.

### Running containers as daemons 

Containers can also used to run daemon application, such as web applications.
For example, to run *Gogs*, a Git Service Application for the software
versioning written in *Go*, the command is:

    $ mkdir /var/gogs
    $ docker run -d -p 3000:3000 -v /var/gogs:/data codeskyblue/docker-gogs

As for the LaTeX image, a volume containing the application configuration files
is mounted, but also the `-d` parameter is used to inform Docker that the
software has to be launched as daemon, and `-p 3000:3000` is used to expose the
service outside the container. Once the daemon is up, the web application can be
visited at `http://localhost:3000`.

### Running a shell inside a container

Sometimes is useful to run a shell inside the environment of a container. In
order to launch a shell inside a container the command is:

    $ docker run --rm -it image_name /bin/bash

The `-i` stands for `--interactive`, and the `-t` is used to allocate a *tty*
device for shell. The `--rm` option is used to destroy the container after the
exit of the shell. The destruction can be safely performed because once a
container is started (for example as a daemon) with a command, will continue to
execute that command until its death. Containers can be stopped, started and
restarted, but once a container is created, the command cannot be changed.

Even if the container is isolated and launching a command inside it can seems
meaningless, is useful when containers are linked in network. For example with
can use a shell for a container that is linked to a database container to
perform a manual manipulation of the data.

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

Containers linking is the base of serving container based applications, that are
divided in different containers, such as:

- Database
- Application Server
- Proxy Server
- Web Interface
- Testing containers

To simplify the process of building, linking and managing a container based
application, *Docker Compose* can be used.

## Docker Compose

## Compose vs Vagrant

## Gasista Felice architecture
