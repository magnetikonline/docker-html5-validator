FROM ubuntu:14.04.1
MAINTAINER Peter Mescalchin "peter@magnetikonline.com"

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install \
	apache2 build-essential \
	libapache2-mod-perl2 libhtml-tidy-perl libosp-dev libxml-libxml-perl libxml2-dev \
	openjdk-6-jre opensp supervisor unzip zlib1g-dev

RUN apt-get clean

RUN mkdir /root/build
ADD ./resource/apache.server.conf /etc/apache2/conf-available/server.conf
ADD ./resource/supervisord.conf /etc/supervisor/conf.d/
ADD http://validator.w3.org/validator.tar.gz /root/build/
ADD http://validator.w3.org/sgml-lib.tar.gz /root/build/
ADD https://github.com/validator/validator/releases/download/20150216/vnu-20150216.jar.zip /root/build/

ADD ./resource/configure.sh /root/build/
WORKDIR /root/build
RUN chmod a+x configure.sh
RUN ./configure.sh

EXPOSE 80

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
