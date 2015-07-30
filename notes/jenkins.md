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

In segiuto si e' abilitata la sicurezza di jenkins al fine di permettere l'utilizzo solo a utenti registrati, e si e' registrato un utente con la possibilita' di svolegere qualsiasi operazione. Una volta aggiunto l'utente si puo' vedere il suo token da utilizzare come chiave nelle API per triggerare le build.

In seguito si e' rivisto il repository di git per adattarlo all'ambiente di CI. Per fare questo si son creati i `docker-compose-ci.yml` e `settings_ci.env` e riadattati i `Dockerfile` per eseguire la build in locale.

Per quanto riguarda il `frontend` sussiste un problema legato a npm, che trova difficolta' nell'installare i pacchetti tramite HTTPS e quindi e' stato forzato temporaneamente a HTTP. Per evitare questo problema si potrebbe pensare di saltare la parte di installazione dei pacchetti e partire da un immagine con i pacchetti gia' installati per copiarci i codici sorgenti del frontend.

Invece per il `backend` sussisteva un problema nella direttiva COPY del Dockerfile in quanto il docker ignore conteneva uno dei file da copiare, che di conseguenza non veniva copiato. Nelle build sul docker-hub questo problema non era presente in quanto si utilizza una versione piu' obosleta (1.6) che non supporta il docker ignore.

Da risolvere il problema bloccante di `nginx` che restituisce `400 BAD REQUEST` alla richiesta di login.

Il problema e' legato a una configurazione errata di Django e si puo' aggirare utilizzando `dev` al posto di `prod` su `APP_ENV` dentro `settings-ci.env`.

Ho linkato insieme Gogs e Jenkins e ho pushato il repository di gasistafelice sulla mia installazione in locale di Gogs. In seguito alle ultime modifiche la build sembra andare a buon fine, rimane solo da definire come impostare il webhook Gogs -> Jenkins per assicurare il Continuous Integration.

Jenkins offre un API REST per permettere a software come Gogs di triggerare build o richiedere altre funzioni. Per ottenere questo pero' e' necessario impostare un token di autenticazione per il job all'interno di jenkins.

    $ curl http://localhost:5000/job/gasistafelice/build -X POST  --user mike:fendstrat --data token=df8d369b7e42a1cd4d6573ed0bec94c0

Per triggerare solo il build invece:

    $ curl http://localhost:5000/git/notifyCommit?url=http://gogs:3000/mike/gasistafelice/
    
La faccenda inizia a farsi interessante poiche' e' necessario fare un two-way linking tra i container gogs e jenkins... come si fa???

    # we export also the 5000 port because jenkins will use the same network stack
    $ docker run --name gogs -d -p 3000:3000 -p 5000:8080 -v /home/michele/Projects/gogs:/data codeskyblue/docker-gogs

    # with --net container:gogs we connect jenkins to the same network as gogs
    $ docker run -d --name jenkins -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker -v /usr/lib/libdevmapper.so.1.02:/usr/lib/libdevmapper.so.1.02 -v /home/michele/Projects/jenkins_home:/var/jenkins_home --net container:gogs michelesr/jenkins

Info sugli HOOK: https://github.com/gogits/gogs/issues/264
