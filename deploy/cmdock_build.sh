#!/bin/zsh

#docker build -t "aiida_workenv:v0.3" .
docker build --platform linux/amd64 -t "aiida_workenv:v0.3" .
