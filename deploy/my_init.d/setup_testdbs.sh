#!/bin/bash
set -em

OVERWRITE_DATABASE(){
        DBNAME=$1
        DBUSER=$2
        psql -c "DROP DATABASE IF EXISTS ${DBNAME};"
        psql -c "CREATE DATABASE ${DBNAME} OWNER ${DBUSER} ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE=template0;"
        psql -c "GRANT ALL PRIVILEGES ON DATABASE ${DBNAME} TO ${DBUSER};"
}

#OVERWRITE_DATABASE test_db_sqlalc ${PGUSER}
#OVERWRITE_DATABASE test_db_django ${PGUSER}

echo 'logging stuff?' > /home/devuser/logfile.txt

