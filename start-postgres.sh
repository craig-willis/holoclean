#!/bin/bash


PGDATA="/home/jovyan/pgdata"
PGSOCKET="/home/jovyan/pgsocket"
PGLOG="/home/jovyan/pgdata/logfile"
PGPORT=5432

export HOLOCLEANHOME=/holoclean 
export PYTHONPATH=$PYTHONPATH:$HOLOCLEANHOME

mkdir -p "$PGSOCKET"

# Initialize PostgreSQL data directory
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Initializing new PostgreSQL data directory..."
    /usr/lib/postgresql/16/bin/initdb -D "$PGDATA"
    /usr/lib/postgresql/16/bin/pg_ctl -D "$PGDATA" -o "-k $PGSOCKET -p $PGPORT" -l "$PGLOG" start
    echo "Creating DB ${POSTGRES_DB}"
    /usr/lib/postgresql/16/bin/createdb -h "$PGSOCKET" -p $PGPORT "jovyan"
    /usr/lib/postgresql/16/bin/createdb -h "$PGSOCKET" -p $PGPORT "$POSTGRES_DB"
    echo "Creating user ${POSTGRES_USER}"
    psql -h "$PGSOCKET" -p $PGPORT -c "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';"
    psql -h "$PGSOCKET" -p $PGPORT -c "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;"
    psql -h "$PGSOCKET" -p $PGPORT -d $POSTGRES_DB -c "GRANT ALL PRIVILEGES ON SCHEMA public TO $POSTGRES_USER;"
    /usr/lib/postgresql/16/bin/pg_ctl -D "$PGDATA" -l "$PGLOG" stop
fi

# Start PostgreSQL
echo "Starting PostgreSQL on port $PGPORT..."
/usr/lib/postgresql/16/bin/pg_ctl -D "$PGDATA" -o "-k $PGSOCKET -p $PGPORT" -l "$PGLOG" start

# Start Jupyter notebook
echo "Starting Jupyter"
tini -g -- pl-gosu-helper.sh start.sh jupyter lab
