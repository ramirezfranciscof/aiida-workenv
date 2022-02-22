#!/bin/zsh

CMDSPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $CMDSPATH
cd ..

docker-compose down -v
