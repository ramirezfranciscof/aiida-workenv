#!/bin/zsh

CMDSPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $CMDSPATH
cd ../build

for i in $CMDSPATH/*.sh; do
    echo $i
done

#docker build -t "aiida_workenv:v0.3" .
#docker build --platform linux/amd64 -t "aiida_workenv:v0.3" .
