# Docker W3C/HTML5 validator instance
Dockerfile for the creation of a self contained W3C Markup validator (with HTML5 validation) instance for fast/offline validation of authored HTML documents.

Setup of such a configuration can be tricky and a little messy so having all this in an isolated and automated way seemed like a good idea.

## Building
To build the Docker image, run the following:

```sh
$ ./build.sh
```

This will take some time (lots to download), performing the following tasks:
- Install Ubuntu base (16.04 LTS), Apache HTTP server, OpenJDK 8, [supervisord](http://supervisord.org/) and a few others.
- Download latest W3C validator source and [Validator.nu](http://validator.github.io/validator/) `vnu.jar` portable HTML5 validator jar.
- Configure Perl/CPAN.
- Install and configure W3C validator (including Validator.nu setup).
- Start Apache and Validator.nu under `supervisord`.

That's the boring/messy stuff out of the way - your new Docker image should now be built.

Alternatively you can pull this image directly from the Docker Hub registry:

```sh
$ docker pull magnetikonline/html5validator
```

## Running
To start the image, run the following:

```sh
$ ./run.sh
```

This will start the image in a new backgrounded container, exposing the following ports:
- Port `80` (Apache2) to host machine on port `8080`.
- Port `8888` (Validator.nu Java server) to host on port `8888`.

You can of course run the container on an alternative local port if you desire by modifying the `docker run -p` switches.

With this complete you should now be able to browse to http://localhost:8080/ and be presented with a working W3C validator instance.
