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

```sh
wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v2.0.0/tensorflow-2.0.0-cp37-none-linux_armv7l.whl
pip uninstall tensorflow
pip install tensorflow-2.0.0-cp37-none-linux_armv7l.whl
```

## Install Jupyter Hub

```sh
sudo apt-get install -y --no-install-recommends \
    npm \
    nodejs 
```

```sh
sudo npm install -g configurable-http-proxy
sudo pip3 install jupyterlab jupyterhub
```

```sh
jupyterhub --generate-config 
sudo mv jupyterhub_config.py /root
```
