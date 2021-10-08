################################################################################
# This Dockerfile will generate the image for the aiida container
#
# Commands:
#
#   $ docker build -t "aiida_workenv:v0.3" .
#
################################################################################
# syntax=docker/dockerfile:1
FROM phusion/baseimage:bionic-1.0.0
################################################################################


# APT GET BASE INSTALLS
#------------------------------------------------------------------------------#
RUN apt-get update && apt-get install -y \
    bash-completion \
    cmake \
    gcc \
    git \
    libpq-dev \
    locate \
    make \
    postgresql-client \
    #Comments also need the bar? \
    ssh \
    sudo \
    vim \
    wget \
&& rm -rf /var/lib/apt/lists/*

# I need some postgres inside the container for some aiida commands
# Do I also need postgresql and/or postgresql-common? pg_ctl should not be necessary
# I need git inside the container to run the pre-commits


# USER SETUP & STARTUP
#------------------------------------------------------------------------------#
#ARG USERNAME="devuser"
#ARG USERPASS="devpass"

#RUN useradd --create-home --shell /bin/bash $USERNAME
#RUN adduser $USERNAME sudo
#RUN echo "$USERNAME:$USERPASS" | chpasswd

#USER $USERNAME # This breaks the init
#WORKDIR /home/${USERNAME}
#ENV SYSTEM_USER ${USERNAME}
#ENV LOGFILE_PATH=/home/devuser/init.log

ENV LOGFILE=/root/init.log
WORKDIR /root

# CONDA & PYTHON
#------------------------------------------------------------------------------#
ENV CONDA_DIR /opt/miniconda
ENV PATH $CONDA_DIR/bin:$PATH

ENV PYTHON_VERSION py39
ENV CONDA_VERSION 4.10.3
#ENV ARCHITECT Linux-aarch64
ENV ARCHITECT Linux-x86_64
ENV MINICONDA_SCRIPT Miniconda3-${PYTHON_VERSION}_${CONDA_VERSION}-${ARCHITECT}.sh
#ENV MINICONDA_SHA256 4879820a10718743f945d88ef142c3a4b30dfc8e448d1ca08e019586374b773f
ENV MINICONDA_SHA256 1ea2f885b4dbc3098662845560bc64271eb17085387a70c2ba3f29fff6f8d52f

RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/${MINICONDA_SCRIPT} && \
    echo "${MINICONDA_SHA256} ${MINICONDA_SCRIPT}" | sha256sum -c - && \
    /bin/bash ${MINICONDA_SCRIPT} -f -b -p ${CONDA_DIR} && \
    echo "conda ${CONDA_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> ${CONDA_DIR}/conda-meta/pinned && \
    conda install --quiet --yes conda && \
    conda install --quiet --yes pip && \
    conda update --all --quiet --yes && \
    conda clean --all -f -y

# This is needed to let non-root users create conda environments.
#RUN touch ${CONDA_DIR}/pkgs/urls.txt

# SETTING UP THE INIT SCRIPTS AND PROFILE
#------------------------------------------------------------------------------#
COPY my_init.d/setup_conda.sh /etc/my_init.d/21_setup_conda.sh
COPY my_init.d/setup_aiida.sh /etc/my_init.d/22_setup_aiida.sh

COPY profile.d/activate_conda.sh /etc/profile.d/.
COPY profile.d/verdi_complete.sh /etc/profile.d/.

CMD ["/sbin/my_init"]


################################################################################
