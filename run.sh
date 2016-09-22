#!/bin/bash -e

# expose container port 80 (original W3C validator engine) and port 8888 (Nu Html Checker)
docker run --detach \
	--publish 8080:80 \
	--publish 8888:8888 \
	magnetikonline/html5validator
