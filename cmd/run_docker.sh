#!/bin/zsh

DIRNAME=$(basename $(dirname "$PWD"))
docker run --name "${DIRNAME}_workenv_1" "aiida_workenv:v0.3"
