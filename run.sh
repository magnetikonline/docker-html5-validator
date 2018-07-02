#!/bin/bash -e

DOCKER_IMAGE_NAME="magnetikonline/html5-validator"


# expose container port 80 (original W3C validator) and port 8888 (Nu Html Checker)
docker run --detach \
	--publish 8080:80 \
	--publish 8888:8888 \
		"$DOCKER_IMAGE_NAME"
