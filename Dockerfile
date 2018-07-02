FROM ubuntu:16.04
LABEL maintainer="Peter Mescalchin <peter@magnetikonline.com>"

ENV W3C_VALIDATOR_SHA1 31cf48c79ccc4c2648125a9606073d013cb107e2
ENV VNU_VALIDATOR_VERSION 17.11.1

RUN apt-get update && apt-get upgrade --yes && \
	apt-get install --yes \
		apache2 build-essential \
		libapache2-mod-perl2 libhtml-tidy-perl libosp-dev libxml-libxml-perl libxml2-dev \
		openjdk-8-jre-headless opensp supervisor unzip zlib1g-dev && \
	apt-get clean

ADD ./resource/apache.server.conf /etc/apache2/conf-available/server.conf
ADD ./resource/supervisord.conf /etc/supervisor/conf.d/
ADD "https://github.com/w3c/markup-validator/archive/$W3C_VALIDATOR_SHA1.zip" "/root/build/markup-validator-$W3C_VALIDATOR_SHA1.zip"
ADD "https://github.com/validator/validator/releases/download/$VNU_VALIDATOR_VERSION/vnu.jar_$VNU_VALIDATOR_VERSION.zip" /root/build/

ADD ./resource/configure.sh /root/build/
WORKDIR /root/build
RUN chmod u+x configure.sh
RUN ./configure.sh "$W3C_VALIDATOR_SHA1" "$VNU_VALIDATOR_VERSION"

EXPOSE 80

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
