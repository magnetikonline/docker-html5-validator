#!/bin/bash

# expose container port 80 (original W3C validator engine) and port 8888 (Nu Html Checker)
docker run -d \
	-p 8080:80 \
	-p 8888:8888 \
	magnetikonline/html5validator
