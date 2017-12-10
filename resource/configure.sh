#!/bin/bash -e

W3C_VALIDATOR_TARGET_BASE_DIR="/usr/local/validator"
W3C_VALIDATOR_CONF="/etc/w3c/validator.conf"
W3C_VALIDATOR_APACHE_CONF="/etc/apache2/conf-available/w3c-validator.conf"
VALIDATOR_NU_BASE_DIR="/root/build/validator.nu"


# read arguments
w3cValidatorSHA1=$1
vnuValidatorVersion=$2

# configure Perl
PERL_MM_USE_DEFAULT=1 \
perl -MCPAN \
	-e "my \$c = \"CPAN::HandleConfig\";" \
	-e "\$c->load(doit => 1,autoconfig => 1);" \
	-e "\$c->edit(prerequisites_policy => \"follow\");\$c->edit(build_requires_install_policy => \"yes\");" \
	-e "\$c->commit();" \
	-e "install Bundle::W3C::Validator;"


# install W3C validator source into place
unzip "markup-validator-$w3cValidatorSHA1.zip"

mkdir --parents /usr/local/validator
mkdir --parents /etc/w3c

w3cValidatorSourceBaseDir="/root/build/markup-validator-$w3cValidatorSHA1"
mv "$w3cValidatorSourceBaseDir/htdocs" "$W3C_VALIDATOR_TARGET_BASE_DIR"
mv "$w3cValidatorSourceBaseDir/share" "$W3C_VALIDATOR_TARGET_BASE_DIR"
mv "$w3cValidatorSourceBaseDir/httpd/cgi-bin" "$W3C_VALIDATOR_TARGET_BASE_DIR"
cp "$w3cValidatorSourceBaseDir/httpd/conf/httpd.conf" "$W3C_VALIDATOR_APACHE_CONF"
cp "$W3C_VALIDATOR_TARGET_BASE_DIR/htdocs/config/"* /etc/w3c

# configure w3c validator and Apache HTTP server

# modify $W3C_VALIDATOR_CONF to allow validation of private IP addresses
cat "$W3C_VALIDATOR_CONF" | \
	sed --regexp-extended "s/(Allow Private IPs =) no/\1 yes/" \
	>"$W3C_VALIDATOR_CONF.tmp"

mv "$W3C_VALIDATOR_CONF.tmp" "$W3C_VALIDATOR_CONF"

# modify $W3C_VALIDATOR_APACHE_CONF to enable SSILegacyExprParser for Apache 2.4.x web server (a requirement for the W3C validator app)
cat "$W3C_VALIDATOR_APACHE_CONF" | \
	sed --regexp-extended "s/(<Directory \/usr\/local\/validator\/htdocs\/>)/\1\n  SSILegacyExprParser on\n/" \
	>"$W3C_VALIDATOR_APACHE_CONF.tmp"

mv "$W3C_VALIDATOR_APACHE_CONF.tmp" "$W3C_VALIDATOR_APACHE_CONF"

# modify $W3C_VALIDATOR_APACHE_CONF to open access for HTTP requests
cat "$W3C_VALIDATOR_APACHE_CONF" | \
	sed --regexp-extended "s/(<LocationMatch \"\^\/\+w3c-validator\/\+\(check\|feedback\(\\\\.html\)\?\)\\$\">)/\1\n  Require all granted\n/" | \
	sed --regexp-extended "s/(<Directory \/usr\/local\/validator\/htdocs\/>)/\1\n  Require all granted\n/" \
	>"$W3C_VALIDATOR_APACHE_CONF.tmp"

mv "$W3C_VALIDATOR_APACHE_CONF.tmp" "$W3C_VALIDATOR_APACHE_CONF"

# modify $W3C_VALIDATOR_APACHE_CONF so validator is accessible from http://[server]:[port]/, not http://[server]:[port]/w3c-validator/
# note: last sed pipe is to default bug introduced by https://github.com/w3c/markup-validator/commit/23b23d378870db3246191571a8b4a06db11d6a28#diff-4dbd8ed550cc192b639299cfba5431bdR80
cat "$W3C_VALIDATOR_APACHE_CONF" | \
	sed --regexp-extended "s/(Alias) \/w3c-validator\//\1 \//" | \
	sed --regexp-extended "s/(RewriteBase) \/w3c-validator\//\1 \//" | \
	sed --regexp-extended "s/(Redirect) \/w3c-validator\//\1 \//" | \
	sed --regexp-extended "s/w3c-validator\/\+//" | \
	sed --regexp-extended "s/\/w3c-validator(\/check)/\1/" | \
	sed --regexp-extended "s/(detailed.html) +(#validate-)/\1\2/" \
	>"$W3C_VALIDATOR_APACHE_CONF.tmp"

mv "$W3C_VALIDATOR_APACHE_CONF.tmp" "$W3C_VALIDATOR_APACHE_CONF"

a2enmod cgid
a2enmod expires
a2enmod include
a2enmod rewrite
a2dismod perl

a2enconf server
a2enconf w3c-validator


# install standalone validator.nu jar to $VALIDATOR_NU_BASE_DIR/vnu.jar
mkdir --parents "$VALIDATOR_NU_BASE_DIR"
unzip -j "vnu.jar_$vnuValidatorVersion.zip" -d "$VALIDATOR_NU_BASE_DIR"

# enable validator.nu within W3C validator $W3C_VALIDATOR_CONF file
cat "$W3C_VALIDATOR_CONF" | \
	sed --regexp-extended "s/#(HTML5 =)/\1/" \
	>"$W3C_VALIDATOR_CONF.tmp"

mv "$W3C_VALIDATOR_CONF.tmp" "$W3C_VALIDATOR_CONF"
