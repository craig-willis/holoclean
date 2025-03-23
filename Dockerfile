FROM prairielearn/workspace-jupyterlab-python

# Set environment variables
ENV PYENV_ROOT=/opt/pyenv \
    PATH=/opt/pyenv/bin:/opt/pyenv/shims:$PATH \
    POSTGRES_USER=holocleanuser \
    POSTGRES_PASSWORD=jupyter \
    POSTGRES_DB=holo \
    DEBIAN_FRONTEND=noninteractive 

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl git ca-certificates \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev libncursesw5-dev libffi-dev \
    liblzma-dev tk-dev \
    postgresql postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

# Install pyenv
RUN curl https://pyenv.run | bash && \
    pyenv install 3.6.15 && \
    $PYENV_ROOT/versions/3.6.15/bin/pip install --no-cache-dir ipykernel && \
    $PYENV_ROOT/versions/3.6.15/bin/python -m ipykernel install --name "python3.6" --display-name "Python 3.6"

RUN service postgresql start && \
    su - postgres -c "psql -c \"CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';\"" && \
    su - postgres -c "psql -c \"CREATE DATABASE $POSTGRES_DB OWNER $POSTGRES_USER;\""

# Configure PostgreSQL to allow password auth
RUN echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/*/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/*/main/postgresql.conf

    
COPY . /holoclean
RUN  cd /holoclean && $PYENV_ROOT/versions/3.6.15/bin/pip install -e .
COPY start-postgres.sh /

USER jovyan

ENTRYPOINT /start-postgres.sh
#ENTRYPOINT ["tini", "-g", "--", "pl-gosu-helper.sh", "/start-postgres.sh", "jupyter", "lab"]
