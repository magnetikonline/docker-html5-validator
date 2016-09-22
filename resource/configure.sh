#!/bin/bash -e

W3C_VALIDATOR_SOURCE_BASE_DIR="/root/build/markup-validator-master"
W3C_VALIDATOR_TARGET_BASE_DIR="/usr/local/validator"
W3C_VALIDATOR_CONF="/etc/w3c/validator.conf"
W3C_VALIDATOR_APACHE_CONF="/etc/apache2/conf-available/w3c-validator.conf"
VALIDATOR_NU_BASE_DIR="/root/build/validator.nu"


# configure Perl
PERL_MM_USE_DEFAULT=1 \
perl -MCPAN \
	-e "my \$c = \"CPAN::HandleConfig\";" \
	-e "\$c->load(doit => 1,autoconfig => 1);" \
	-e "\$c->edit(prerequisites_policy => \"follow\");\$c->edit(build_requires_install_policy => \"yes\");" \
	-e "\$c->commit();" \
	-e "install Bundle::W3C::Validator;"


# install W3C validator source into place
unzip markup-validator-master.zip

mkdir -p /usr/local/validator
mkdir -p /etc/w3c

mv "$W3C_VALIDATOR_SOURCE_BASE_DIR/htdocs" "$W3C_VALIDATOR_TARGET_BASE_DIR"
mv "$W3C_VALIDATOR_SOURCE_BASE_DIR/share" "$W3C_VALIDATOR_TARGET_BASE_DIR"
mv "$W3C_VALIDATOR_SOURCE_BASE_DIR/httpd/cgi-bin" "$W3C_VALIDATOR_TARGET_BASE_DIR"
cp "$W3C_VALIDATOR_SOURCE_BASE_DIR/httpd/conf/httpd.conf" "$W3C_VALIDATOR_APACHE_CONF"
cp $W3C_VALIDATOR_TARGET_BASE_DIR/htdocs/config/* /etc/w3c

# configure w3c validator and Apache HTTP server

# modify $W3C_VALIDATOR_CONF to allow validation of private IP addresses
cat $W3C_VALIDATOR_CONF | \
	sed -r "s/Allow Private IPs = no/Allow Private IPs = yes/" \
	>"$W3C_VALIDATOR_CONF.tmp"

mv "$W3C_VALIDATOR_CONF.tmp" $W3C_VALIDATOR_CONF

# modify $W3C_VALIDATOR_APACHE_CONF to enable SSILegacyExprParser for Apache 2.4.x web server (a requirement for the W3C validator app)
cat $W3C_VALIDATOR_APACHE_CONF | \
	sed -r "s/<Directory \/usr\/local\/validator\/htdocs\/>/<Directory \/usr\/local\/validator\/htdocs\/>\n  SSILegacyExprParser on\n/" \
	>"$W3C_VALIDATOR_APACHE_CONF.tmp"

mv "$W3C_VALIDATOR_APACHE_CONF.tmp" $W3C_VALIDATOR_APACHE_CONF

# modify $W3C_VALIDATOR_APACHE_CONF to open access for HTTP requests
cat $W3C_VALIDATOR_APACHE_CONF | \
	sed -r "s/<Directory \/usr\/local\/validator\/htdocs\/>/<Directory \/usr\/local\/validator\/htdocs\/>\n  Require all granted\n/" | \
	sed -r "s/<LocationMatch \"\^\/\+w3c-validator\/\+\(check\|feedback\(\\\\.html\)\?\)\\$\">/<LocationMatch \"^\/+w3c-validator\/+(check|feedback(\\\.html)?)$\">\n  Require all granted\n/" \
	>"$W3C_VALIDATOR_APACHE_CONF.tmp"

mv "$W3C_VALIDATOR_APACHE_CONF.tmp" $W3C_VALIDATOR_APACHE_CONF

# modify $W3C_VALIDATOR_APACHE_CONF so validator is accessible from http://[server]:[port]/, not http://[server]:[port]/w3c-validator/
cat $W3C_VALIDATOR_APACHE_CONF | \
	sed -r "s/Alias \/w3c-validator\//Alias \//" | \
	sed -r "s/RewriteBase \/w3c-validator\//RewriteBase \//" | \
	sed -r "s/Redirect \/w3c-validator\//Redirect \//" | \
	sed -r "s/w3c-validator\/\+//" | \
	sed -r "s/\/w3c-validator\/check/\/check/" \
	>"$W3C_VALIDATOR_APACHE_CONF.tmp"

mv "$W3C_VALIDATOR_APACHE_CONF.tmp" $W3C_VALIDATOR_APACHE_CONF

a2enmod cgid
a2enmod expires
a2enmod include
a2enmod rewrite
a2dismod perl

a2enconf server
a2enconf w3c-validator


# install standalone validator.nu jar to $VALIDATOR_NU_BASE_DIR/vnu.jar
mkdir -p $VALIDATOR_NU_BASE_DIR
unzip -j vnu[-.]*.zip -d $VALIDATOR_NU_BASE_DIR

# enable validator.nu within W3C validator $W3C_VALIDATOR_CONF file
cat $W3C_VALIDATOR_CONF | \
	sed -r "s/#HTML5 =/HTML5 =/" | \
	sed -r "s/#CompoundXML =/CompoundXML/" \
	>"$W3C_VALIDATOR_CONF.tmp"

mv "$W3C_VALIDATOR_CONF.tmp" $W3C_VALIDATOR_CONF

# success
exit 0
