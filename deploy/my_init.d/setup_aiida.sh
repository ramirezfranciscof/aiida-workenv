#!/bin/bash

# Debugging.
set -x

echo "Checking conda env" >>"${LOGFILE}" 2>&1
${CONDA_DIR}/bin/conda env list >>"${LOGFILE}" 2>&1
cd /root/codes
pwd >>"${LOGFILE}" 2>&1
pip -V >>"${LOGFILE}" 2>&1
pip install -e ./aiida-core[tests,pre-commit,docs,rest,atomic_tools,notebook,bpython] >>"${LOGFILE}" 2>&1
pip freeze >>"${LOGFILE}" 2>&1
echo "Finished checks." >>"${LOGFILE}" 2>&1

