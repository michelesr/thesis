# Continuous Integration

## Gogs - Go Git Service

*Gogs* (Go Git Service) is an open source lightweight Git Service that will be
used as *SCM* (Source Code Management) tool. Gogs is written in the Go
programming language, that is a compiled language. Go uses a static linking of
libraries for producing a single binary that can be run in all Linux
distribution without install any dependency, so Gogs is composed of a single
binary. In order to install Gogs, a prebuilt image from Docker Hub can be used:

    $ docker pull codeskyblue/docker-gogs
    $ docker run --name gogs -d \
          -p 3000:3000 \
          -p 5000:8080 \
          -v $HOME/gogs_data:/data \
          codeskyblue/docker-gogs

The ports `3000` and `8080` will be exported respectively to `3000` and `5000`
of our host. The port `3000` is reserved for the Gogs service, while the `8080`
will be used for the Continuous Integration system that will be linked with Gogs
later. Gogs require a directory for the configuration file and data storage, so
`$HOME/gogs_data` has been mounted inside the container as `/data`.

### Configuration

Opening the browser at `http://localhost:3000/` will redirect to the first
configuration page. The configuration to adopt is:

- Database type:  `SQLite3`
- Database path: `data/gogs.db`
- Repository Root Path: `/home/git/repositories`
- Run User: `git`
- Domain: `localhost`
- HTTP Port: `3000`
- Application URL: `http://localhost:3000/`

For the admin account:

- Username: `SuperUser`
- Password: `*********`
- Email: `superuser@example.org`

Settings are confirmed with `Install Gogs` button. Then a normal user account
has to be registered through the `Register` button:

- Username: `Mike`
- Email: `mikefender@cryptolab.net`
- Password: `*********`

### Pushing the Gasista Felice repository

After the registration and sign in, a repository for Gasista Felice named
`gasistafelice` has to be created. After the creation, the local repository can
be pushed on the Gogs server using git:

    $ cd path/to/gasistafelice/
    $ git remote add gogs http://localhost:3000/mike/gasistafelice.git

    $ git push gogs master
    Username for 'http://localhost:3000': Mike
    Password for 'http://Mike@localhost:3000':
    Counting objects: 22003, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (7984/7984), done.
    Writing objects: 100% (22003/22003), 19.19 MiB | 37.32 MiB/s, done.
    Total 22003 (delta 13947), reused 21384 (delta 13454)
    To http://localhost:3000/mike/gasistafelice.git
    * [new branch]      master -> master

<!-- ![Commits page for `dev` branch of Gasista Felice on Gogs](images/gasistafelice_commits.png) -->

Note: the http protocol has been used for the push because Gogs is running in a
local environment, and, for security reasons, needs to be replaced with http or
ssh when the SCM system is running in a remote server.

## Jenkins

*Jenkins* is a open source software for Continuous Integration written in Java.
It permits to run scheduled jobs and to schedule periodical or triggered
automated build for the continuous integration.

To build and test container based applications, Jenkins container require to
access a Docker daemon, and two different approach are available for the
purpose:

- grant access to the host Docker daemon inside the Jenkins container
- use HTTPS to talk to the Docker daemon
- install Docker inside the Jenkins container

In term of security, the HTTPS based solution is the worst because expose Docker
daemon on the network. The other two solution instead are on the same security
level. Sharing the Docker daemon on the host allow trusted users in Jenkins to
mount host volumes with write permission using Docker, while installing and
running Docker inside a container require the creation of privileged container
that can access all the host features including kernel features and device
access. In every case, using a container for Jenkins is always better than
installing Jenkins in the host system because Docker provides a layer of
isolation from the system resources.

For the purpose of this project, the first solution has been adopted, because it
allows the reuse of the installed and cached images in the host, reducing
building and testing times. In fact, Docker implements a smart caching system
that avoid rebuilding images if is not necessary.

![Jenkins interaction with Docker and Testing
environment](images/jenkins-docker.eps)

### Installation

In order to install Jenkins and the support software, a custom Dockerfile is
required:

    FROM jenkins:1.596
    
    MAINTAINER Michele Sorcinelli "mikefender@cryptolab.net"
     
    USER root
    RUN apt-get update \
          && apt-get install -y python python-pip sudo \
          && rm -rf /var/lib/apt/lists/*
    RUN pip install docker-compose
    RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
     
    USER jenkins
    COPY plugins.txt /usr/share/jenkins/plugins.txt
    RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

In this Dockerfile, starting from a Jenkins base image,  `python2`, `pip`
(Python Package Manager), `docker-compose` and `sudo` are installed, then
superuser privileges are granted to the jenkins user in order to permit the use
of Docker. Note that the Docker daemon can be accessed without superuser
privileges if the user is added to the `docker` group, but this can't be done
inside the Jenkins container so sudo is required. The `plugins.txt` file
containing the list of plugin to install copied inside the container is:

    scm-api:latest
    git-client:latest
    git:latest
    greenballs:latest

The command to properly run the Jenkins container, giving him the access to
docker and connecting him to the gogs network is:

    $ docker pull michelesr/jenkins
    $ mkdir $HOME/jenkins_data
    $ docker run --name jenkins -d \
         -v /var/run/docker.sock:/var/run/docker.sock \
         -v /usr/lib/libdevmapper.so.1.02:/usr/lib/libdevmapper.so.1.02 \
         -v $(which docker):/usr/bin/docker \
         -v $HOME/jenkins_data:/var/jenkins_home \
         --net container:gogs \
         michelesr/jenkins

In order to grant access to the Docker daemon inside the container, the UNIX
socket `/var/run/docker.sock`, the docker client (retrieved with the bashism
`$(which docker)`), the device mapper library `/usr/lib/libdevmmaper.so.1.02`,
and a directory for jenkins data have to be mounted. With the `--net
container:gogs` parameter, the Jenkins container will share the same network
stack of the Gogs container, and the they will be able to communicate connecting
to the loopback device `localhost`.

Note that this process has been tested on an Arch Linux distribution and some
parameters (such as the library path) can be different in another distribution.
Also the `jenkins_data` directory must belong to the same UUID as the jenkins
user (`1000`). The UUID of the current user can be found with the command:

    $ cat /etc/passwd | grep $(whoami)
    michele:x:1000:1000::/home/michele:/usr/bin/zsh

If the users doesn't match, using of UUID `1000` can always be forced with:

    # chmod 1000:1000 $HOME/jenkins_data
    
If Gogs is up and has been launched with the command provided previously,
Jenkins can be accessed at the URL `http://localhost:5000`, because the port for
the Jenkins service has been exported at the Gogs launch.

### Security Configuration

The first configuration to do once launched Jenkins is setup the security,
through the page at `http://localhost:5000/configureSecurity/`. To enable
security, the `Enable security` checkbox must be checked, and these options have
to be setted:

- TCP Port for JNLP slave agents: `Disable`
- Security realm: `Jenkins own user database`
- Allow user to sign-up: `unchecked`

After confirming, an user must be added accessing the page at the URL:
`http://localhost:5000/securityRealm/addUser`:

- Username: `mike`
- Password: `*********`
- Full name: `Michele Sorcinelli`
- E-mail address: `mikefender@cryptolab.net`

Then the access to unlogged user can be disabled returning to the security
configuration page and setting:

- Authorization: `Logged-in users can do anything`

### Setting up a Job for Gasista Felice

Navigating to the page `http://localhost:5000/newJob` a new job for the Gasista
Felice project can be setted choosing the `Freestyle Project` option and
`gasistafelice` as project name. Configuration for the project is:

- Source Code Management: `Git`
- Build: `Add build step -> Execute Shell`
- Repository URL: `http://localhost:3000/Mike/gasistafelice`
- Credential: `Add -> Username with Password`
- Username: `Mike`
- Password: `********`
- Branches to build: `dev-ci`
- Build Triggers: `Poll SCM`
- Schedule: leave blank

The command to build is:

    mv docker-compose-ci.yml docker-compose.yml
    sudo docker-compose build
    sudo make up
    sudo make dbtest
    sudo make test
    sudo docker-compose stop 

The `docker-compose-ci.yml` is renamed to `docker-compose.yml`, replacing the
configuration used for development with the one used in continuous integration
builds, that is more similar to the production environment configuration. Docker
Compose is used to build the container from the Dockerfiles, link and run them,
then the test database is loaded and the test are launched. Before finishing the
build, the containers are stopped.  

### Add a hook for triggering a SCM pull

In order to trigger the source code pulling from Jenkins when a push on the SCM
is performed, we must add an hook for the `gasistafelice` repository in Gogs:

    $ cd $HOME/gogs_data/git/repositories/mike/gasistafelice.git/hooks
    $ sudo vi post-receive

The `post-recieve` hook script content is:

    #! /bin/sh 
    curl http://localhost:8080/git/notifyCommit\
    ?url=http://localhost:3000/Mike/gasistafelice/ \
    2>/dev/null

Then the script permission must be setted:
    
    $ sudo chown 999:999 post-receive
    $ sudo chmod -x post-receive

To test the configuration, push to the remote `gasistafelice` repository:

    $ cd path/to/gasistafelice/
    $ git checkout dev-ci
    Switched to branch 'dev-ci'
    $ git push gogs dev-ci
    Counting objects: 12, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (11/11), done.
    Writing objects: 100% (12/12), 1.51 KiB | 0 bytes/s, done.
    Total 12 (delta 5), reused 0 (delta 0)
    remote: Scheduled polling of gasistafelice
    To http://localhost:3000/mike/gasistafelice.git
     * [new branch]      dev-ci -> dev-ci

As can be seen from the command output, a poll of `gasistafelice` has been
scheduled by Jenkins and if changes are found on the `dev-ci` branch, the
project will be built and tested. The branches to be tracked can be setted in
the Job Configuration of Jenkins. The status of all the build of the project can
be found at the url: `http://localhost:5000/job/gasistafelice/`.

![Gogs triggers a SCM pull in reply to a developer
push](images/jenkins-poll.eps)