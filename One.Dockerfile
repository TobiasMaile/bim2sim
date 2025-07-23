ARG PYTHON_VERSION=3.10
FROM mambaorg/micromamba:2.0.2

# Declare ARG again after FROM
ARG PYTHON_VERSION

# Set the Python version as an environment variable
ENV PYTHON_VERSION=${PYTHON_VERSION}

# Ensure Micromamba uses UTF-8
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Install Python + dependencies in base env
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes

ENV GIT_PYTHON_GIT_EXECUTABLE=/opt/conda/bin/git
ENV PIP_DEFAULT_TIMEOUT=500

# Copy your source code (bim2sim) and set permissions
COPY --chown=$MAMBA_USER:$MAMBA_USER . /home/$MAMBA_USER/bim2sim

# Install Python packages
WORKDIR /home/$MAMBA_USER/bim2sim
RUN micromamba run -n base pip install --no-cache-dir '.' -i https://pypi.org/simple
RUN micromamba run -n base pip install --no-cache-dir -e '.[PluginEnergyPlus]'

# EnergyPlus install
USER root
ENV ENERGYPLUS_VERSION=9.4.0
ENV ENERGYPLUS_TAG=v9.4.0
ENV ENERGYPLUS_SHA=998c4b761e
ENV ENERGYPLUS_INSTALL_VERSION=9-4-0
ENV ENERGYPLUS_DOWNLOAD_BASE_URL https://github.com/NREL/EnergyPlus/releases/download/$ENERGYPLUS_TAG
ENV ENERGYPLUS_DOWNLOAD_FILENAME EnergyPlus-$ENERGYPLUS_VERSION-$ENERGYPLUS_SHA-Linux-Ubuntu18.04-x86_64.sh
ENV ENERGYPLUS_DOWNLOAD_URL $ENERGYPLUS_DOWNLOAD_BASE_URL/$ENERGYPLUS_DOWNLOAD_FILENAME

RUN apt-get update && apt-get install -y ca-certificates curl libx11-6 libexpat1 && \
    curl -SLO $ENERGYPLUS_DOWNLOAD_URL && \
    chmod +x $ENERGYPLUS_DOWNLOAD_FILENAME && \
    echo "y\r" | ./$ENERGYPLUS_DOWNLOAD_FILENAME && \
    rm $ENERGYPLUS_DOWNLOAD_FILENAME && \
    cd /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION && \
    rm -rf DataSets Documentation ExampleFiles WeatherData MacroDataSets PostProcess/convertESOMTRpgm \
           PostProcess/EP-Compare PreProcess/FMUParser PreProcess/ParametricPreProcessor PreProcess/IDFVersionUpdater && \
    cd /usr/local/bin && find -L . -type l -delete

# Make sure all relevant files are accessible by the micromamba user
RUN chown -R $MAMBA_USER:$MAMBA_USER /home/$MAMBA_USER /usr/local/EnergyPlus-$ENERGYPLUS_INSTALL_VERSION

# Set working directory & volume
USER $MAMBA_USER
WORKDIR /home/$MAMBA_USER/bim2sim
VOLUME /var/simdata/energyplus
