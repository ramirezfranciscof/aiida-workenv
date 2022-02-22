#!/bin/bash
set -x # debugging
#exec >> /root/inits.log 2>&1;

# Setup ssh keys for self-login
for pubfile in /root/.ssh/*.pub; do
    cat $pubfile >> /root/.ssh/authorized_keys
done
/etc/init.d/ssh start

# Virtual env
source /root/.virtualenvs/aiida/bin/activate
cd /root/workdir/aiida-core
pip install --upgrade pip
pip install -e .[tests,ssh_kerberos,rest,docs,atomic_tools,notebook,pre-commit,bpython]
pre-commit install

# Setup main profile (if it doesn't exist)
if verdi profile list | grep -q 'main_profile'; then
    echo 'main_profile is already set up'
else
    verdi setup --non-interactive --profile main_profile \
        --first-name firstname --last-name lastname --email name@email.com --institution institution \
#        --db-username postgres --db-password postgres --db-name main_aiidadb --db-backend psql_dos \
        --db-username postgres --db-password postgres --db-name main_aiidadb --db-backend sqlalchemy \
#        --db-username postgres --db-password postgres --db-name main_aiidadb --db-backend django \
        --broker-host rmq --db-host pdb
    verdi profile setdefault main_profile
fi

# Setup test profile (overwrite existing)
if verdi profile list | grep -q 'test_profile'; then
#  verdi profile delete --include-db --include-repository --include-config --include-db-user -f test_profile
  verdi profile delete --include-db --include-repository --include-config -f test_profile
fi

verdi quicksetup --non-interactive --profile test_profile \
    --first-name testname --last-name testsurname \
    --email developer@email.com --institution institution \
#    --db-name test_aiidadb --db-backend psql_dos \
    --db-name test_aiidadb --db-backend sqlalchemy \
#    --db-name test_aiidadb --db-backend django \
    --db-host pdb --broker-host rmq

echo '' >> /root/.virtualenvs/aiida/bin/activate
echo 'export AIIDA_TEST_PROFILE=test_profile' >> /root/.virtualenvs/aiida/bin/activate

echo '' >> /root/.virtualenvs/aiida/bin/activate
echo 'eval "$(_VERDI_COMPLETE=source verdi)"' >> /root/.virtualenvs/aiida/bin/activate


