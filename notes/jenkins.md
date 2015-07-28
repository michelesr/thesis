# Continuous integration con Jenkins 

Cosa e' stato fatto finora:

Partendo da questo [articolo](http://container-solutions.com/running-docker-in-jenkins-in-docker/) si e' creato un
Dockerfile per buildare Jenkins con il supporto a docker-compose... il Dockerfile e' il seguente:

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

In particolare si e' aggiunto `sudo` per permettere al container di accedere al demone docker dell'host e aggiunto il supporto a `docker-compose`.

Il comando per lanciare jenkins e' il seguente:

    docker run -d --name jenkins -v /var/run/docker.sock:/var/run/docker.sock \ 
               -v $(which docker):/usr/bin/docker \
               -v /usr/lib/libdevmapper.so.1.02:/usr/lib/libdevmapper.so.1.02 \
               -v $HOME/Projects/jenkins_home:/var/jenkins_home \ 
               -p 5000:8080 michelesr/jenkins

In seguito si e' rivisto il repository di git per adattarlo all'ambiente di CI. Per fare questo si son creati i `docker-compose-ci.yml` e `settings_ci.env` e riadattati i `Dockerfile` per eseguire la build in locale.

Per quanto riguarda il `frontend` sussiste un problema legato a npm, che trova difficolta' nell'installare i pacchetti tramite HTTPS e quindi e' stato forzato temporaneamente a HTTP. Per evitare questo problema si potrebbe pensare di saltare la parte di installazione dei pacchetti e partire da un immagine con i pacchetti gia' installati per copiarci i codici sorgenti del frontend.

Invece per il `backend` sussisteva un problema nella direttiva COPY del Dockerfile in quanto il docker ignore conteneva uno dei file da copiare, che di conseguenza non veniva copiato. Nelle build sul docker-hub questo problema non era presente in quanto si utilizza una versione piu' obosleta (1.6) che non supporta il docker ignore.
