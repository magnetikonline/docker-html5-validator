FROM ubuntu:16.04
MAINTAINER Peter Mescalchin <peter@magnetikonline.com>

RUN apt-get update && apt-get -y upgrade && \
	apt-get -y install \
		apache2 build-essential \
		libapache2-mod-perl2 libhtml-tidy-perl libosp-dev libxml-libxml-perl libxml2-dev \
		openjdk-8-jre-headless opensp supervisor unzip zlib1g-dev && \
	apt-get clean

ADD ./resource/apache.server.conf /etc/apache2/conf-available/server.conf
ADD ./resource/supervisord.conf /etc/supervisor/conf.d/
ADD https://github.com/w3c/markup-validator/archive/master.zip /root/build/markup-validator-master.zip
ADD https://github.com/validator/validator/releases/download/16.6.29/vnu.jar_16.6.29.zip /root/build/

ADD ./resource/configure.sh /root/build/
WORKDIR /root/build
RUN chmod u+x configure.sh
RUN ./configure.sh

EXPOSE 80

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
