# Docker W3C/HTML5 validator instance
Dockerfile for the creation of a self contained W3C Markup validator (with HTML5 validation) instance for fast/offline validation of authored HTML documents.

Setup of such a configuration can be tricky and a little messy so having all this in an isolated and automated way seemed like a good idea.

## Building
To build the Docker image, run the following:

```sh
$ ./build.sh
```

This will take some time (lots to download), performing the following tasks:
- Install Ubuntu base (14.04), Apache HTTP server, OpenJDK 6, [supervisord](http://supervisord.org/) and a few others.
- Download latest W3C validator source and [Validator.nu](http://validator.github.io/) `vnu.jar` portable HTML5 validator jar.
- Configure Perl/CPAN
- Install and configure W3C validator (including Validator.nu setup).
- Start Apache and Validator.nu under `supervisord`.

That's the boring/messy stuff out of the way - your new Docker image should now be built.

Alternatively you can pull this image directly from the Docker Hub Registry:

```sh
$ sudo docker pull magnetikonline/html5validator
```

## Running
To execute the image, run the following:

```sh
$ ./run.sh
```

This will start the image in a new detached container and expose port `80` (Apache2) to your host machine on port `8080`. You can of course run the container on an alternative local port if you desire by modifying the `docker run -p` switch.

With this complete you should now be able to browse to `http://localhost:8080/` and be presented with a working W3C validator instance.
