#!/bin/zsh

CMDSPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $CMDSPATH
cd ..

mkdir -p data/aiida
mkdir -p data/codes
mkdir -p data/dbase
mkdir -p data/dbase

#docker-compose up -d
docker-compose up
