#!/bin/bash

set -em

LOGFILE=/home/devuser/init.log

# Prepare conda. Otherwise creation of a new conda environment will fail.
echo "Starting conda setups..." > ${LOGFILE}
chown ${SYSTEM_USER}:${SYSTEM_USER} /home/${SYSTEM_USER} -R
su ${SYSTEM_USER} -c "${CONDA_DIR}/bin/conda init" > ${LOGFILE}
echo "Conda setups finished." > ${LOGFILE}

