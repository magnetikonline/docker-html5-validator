#!/bin/bash

# expose container port 80 (original W3C validator engine)
sudo docker run -dp 8080:80 magnetikonline/html5validator
