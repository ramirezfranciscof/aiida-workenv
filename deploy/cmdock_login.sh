#!/bin/zsh

#DIRNAME=${PWD##*/}
DIRNAME=$(basename $(dirname "$PWD"))
#docker exec -it --user devuser ${DIRNAME}_workenv_1 /bin/bash
docker exec -it ${DIRNAME}_workenv_1 /bin/bash

