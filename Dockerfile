FROM ubuntu:14.04.3
MAINTAINER Peter Mescalchin "peter@magnetikonline.com"

RUN apt-get update && apt-get -y upgrade

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:webupd8team/java -y
RUN apt-get update
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

RUN apt-get -y install \
  apache2 build-essential \
  libapache2-mod-perl2 libhtml-tidy-perl libosp-dev libxml-libxml-perl libxml2-dev \
  oracle-java8-set-default opensp supervisor unzip zlib1g-dev

RUN apt-get clean

ADD ./resource/apache.server.conf /etc/apache2/conf-available/server.conf
ADD ./resource/supervisord.conf /etc/supervisor/conf.d/
ADD https://github.com/w3c/markup-validator/archive/master.zip /root/build/markup-validator-master.zip
ADD https://github.com/validator/validator/releases/download/16.3.3/vnu.jar_16.3.3.zip /root/build/

ADD ./resource/configure.sh /root/build/
WORKDIR /root/build
RUN chmod u+x configure.sh
RUN ./configure.sh

EXPOSE 80

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
