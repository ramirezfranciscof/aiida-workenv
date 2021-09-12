# syntax=docker/dockerfile:1
FROM phusion/baseimage:bionic-1.0.0

# Use the following arguments during *build* time:
# $ docker build  --build-arg NB_UID=200
ARG NB_USER="aiida"
ARG NB_UID="1000"
ARG NB_GID="1000"

# Use the following variables when running docker:
# $ docker run -e SYSTEM_USER=aiida2
ENV SYSTEM_USER ${NB_USER}
ENV SYSTEM_USER_UID ${NB_UID}
ENV SYSTEM_USER_GID ${NB_GID}
ENV PYTHONPATH /home/$SYSTEM_USER
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

# Modify this section for the conda/python update.
# This list of miniconda installer versions together with their SHA256 check sums are available:
# https://docs.conda.io/en/latest/miniconda_hashes.html
ENV PYTHON_VERSION py37
ENV CONDA_VERSION 4.9.2
ENV MINICONDA_VERSION ${PYTHON_VERSION}_${CONDA_VERSION}
ENV MINICONDA_SHA256 79510c6e7bd9e012856e25dcb21b3e093aa4ac8113d9aa7e82a86987eabe1c31

# Always activate /etc/profile, otherwise conda won't work.
ENV BASH_ENV /etc/profile

USER root

# Fix locales.
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Add switch mirror to fix the issue.
# https://github.com/aiidalab/aiidalab-docker-stack/issues/9
RUN echo "deb http://mirror.switch.ch/ftp/mirror/ubuntu/ bionic main \ndeb-src http://mirror.switch.ch/ftp/mirror/ubuntu/ bionic main \n" >> /etc/apt/sources.list

# Install debian packages.
# Note: prefix all 'apt-get install' lines with 'apt-get update' to prevent failures in partial rebuilds
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    tzdata

# Install required ubuntu packages.
RUN apt-get update && apt-get install -y --no-install-recommends  \
    build-essential       \
    bzip2                 \
    git                   \
    gir1.2-gtk-3.0        \
    gnupg                 \
    graphviz              \
    locales               \
    less                  \
    postgresql-client     \
    psmisc                \
    rsync                 \
    #sudo                  \
    #make                  \
    #cmake                 \
    #gcc                   \
    #libpq-dev             \
    ssh                   \
    unzip                 \
    vim                   \
    wget                  \
    zip                   \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean all

# Install conda.
RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "${MINICONDA_SHA256} *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | sha256sum -c - && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_DIR/conda-meta/pinned && \
    conda install --quiet --yes conda && \
    conda install --quiet --yes pip && \
    conda update --all --quiet --yes && \
    conda clean --all -f -y

# Upgrade ruamel.py version. Fixes https://github.com/aiidateam/aiida-core/issues/4339.
RUN conda install ruamel.yaml==0.16.10

# This is needed to let non-root users create conda environments.
RUN touch /opt/conda/pkgs/urls.txt

# Copy the script load-singlesshagent.sh to /usr/local/bin.
COPY bin/load-singlesshagent.sh /usr/local/bin/load-singlesshagent.sh

# Create system user.
COPY my_init.d/create-system-user.sh /etc/my_init.d/10_create-system-user.sh

# Launch rabbitmq server
COPY my_init.d/start-rabbitmq.sh /etc/my_init.d/20_start-rabbitmq.sh

# Launch postgres server.
COPY opt/start-postgres.sh /opt/start-postgres.sh
COPY my_init.d/start-postgres.sh /etc/my_init.d/30_start-postgres.sh

# Check if init script is finished.
COPY my_init.d/finalize_init.sh /etc/my_init.d/99_finalize_init.sh

# Add wait-for-services script.
COPY bin/wait-for-services /usr/local/bin/wait-for-services

# Enable prompt color in the skeleton .bashrc before creating the default ${SYSTEM_USER}.
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Always activate conda.
COPY profile.d/activate_conda.sh /etc/profile.d/

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]


# USER SETUP
#------------------------------------------------------------------------------#
#ARG USERNAME="devuser"
#ARG USERPASS="devpass"
#
#RUN useradd --create-home --shell /bin/bash $USERNAME
#RUN adduser $USERNAME sudo
#RUN echo "$USERNAME:$USERPASS" | chpasswd

#USER $USERNAME
#WORKDIR /home/$USERNAME
#ENV PATH "$PATH:/home/max/.local/bin"

#WORKDIR /root


# CONDA & PYTHON
#------------------------------------------------------------------------------#
#RUN apt-get -y update
#RUN apt-get -y install git python3 python3-pip python3-dev

# I need conda for using python3, apparently ubuntu uses python2 by default
#RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*

#ENV PATH="/root/miniconda3/bin:${PATH}"
#ARG PATH="/root/miniconda3/bin:${PATH}"

#RUN wget \
#    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
#    && mkdir /root/.conda \
#    && bash Miniconda3-latest-Linux-x86_64.sh -b \
#    && rm -f Miniconda3-latest-Linux-x86_64.sh 
#RUN conda --version

#RUN conda create -n aiida -c conda-forge aiida-core


#RUN apk add --no-cache python g++ make
#WORKDIR /app
#COPY . .
#RUN yarn install --production
#CMD ["node", "src/index.js"]

# Leave for default user and dir when launching container
#USER max
#WORKDIR /home/max
