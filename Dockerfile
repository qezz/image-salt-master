FROM ubuntu:20.04

RUN apt update
RUN apt install -y gnupg curl wget libzmq3-dev

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN wget -q https://repo.saltstack.com/py3/ubuntu/20.04/amd64/3004/SALTSTACK-GPG-KEY.pub && \
    apt-key add SALTSTACK-GPG-KEY.pub && \
    rm SALTSTACK-GPG-KEY.pub
RUN echo "deb [arch=amd64] http://repo.saltstack.com/py3/ubuntu/20.04/amd64/3004 focal main" > /etc/apt/sources.list.d/saltstack.list
RUN apt update
RUN apt install -y salt-common salt-master salt-minion salt-ssh salt-api
RUN apt clean all

RUN sed -i "s|#auto_accept: False|auto_accept: True|g" /etc/salt/master
# RUN echo 'rest_cherrypy:\n  host: "127.0.0.1"\n  port: 8000\n  disable_ssl: 1' >>  /etc/salt/master
# RUN echo 'rest_cherrypy:\n  port: 8000\n  disable_ssl: 1' >>  /etc/salt/master

RUN echo 'rest_cherrypy:\n  port: 8000\n  disable_ssl: 1\n\nexternal_auth:\n  auto: {"salt": [".*"]}' >> /etc/salt/master.d/cherrypy.conf

ENTRYPOINT ["bash", "-c", "salt-master -l debug & salt-api" ]
