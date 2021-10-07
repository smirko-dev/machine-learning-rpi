# Machine Learning on a Raspberry Pi

## Setup environment

### Install packages

```sh
sudo apt-get update && sudo apt-get upgrade

apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    libc-ares-dev \
    libatlas-base-dev \
    libhdf5-dev \
    libeigen3-dev \
    libopenjp2-7-dev \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-scipy \
    wget \
    && \
    apt-get clean
```

### Switch to Python 3

```sh
sudo pip3 install --upgrade pip
sudo rm /usr/bin/python 
sudo ln -s /usr/bin/python3 /usr/bin/python
```

### Install Python modules

```sh
sudo pip3 install \
    keras_applications \
    keras_preprocessing \
    matplot \
    numpy \
    pandas \
    wheel
```

### Install Tensorflow

Since there are Python wheels available for ARM architecture at https://github.com/lhelontra/tensorflow-on-arm/releases we don't need to build from scratch.

```sh
wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v2.4.0/tensorflow-2.4.0-cp37-none-linux_armv7l.whl
pip3 uninstall tensorflow
pip3 install tensorflow-2.4.0-cp37-none-linux_armv7l.whl
```

## Install Jupyter Hub

### Install packages

```sh
sudo apt-get install -y --no-install-recommends \
    npm \
    nodejs

sudo npm install -g configurable-http-proxy
```

### Install Python modules

```sh
sudo pip3 install \
    jupyterlab \
    jupyterhub
```

### Create JupyterHub configuration

```sh
jupyterhub --generate-config 
sudo mv jupyterhub_config.py /root
```
