# Machine Learning with JupyterLab on a Raspberry Pi

Run [Jupyter Lab](https://jupyter.org) with [Tensorflow](https://www.tensorflow.org) on a [Raspberry Pi](https://www.raspberrypi.org) as a service for remote access.

[Setup environment](#setup-environment)

[Install Tensorflow](#install-tensorflow)

[Install Jupyter Lab](#install-jupyter-lab)

[Install R and IRkernel](#install-r-and-irkernel) (experimental!)

[Docker](#use-docker-container)

[Links](#links)

## Setup environment

### Install packages

```sh
sudo apt-get update && sudo apt-get upgrade

apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    gfortran \
    libc-ares-dev \
    libopenblas-dev \
    libblas-dev \
    liblapack-dev \
    libatlas-base-dev \
    libhdf5-dev \
    libeigen3-dev \
    libopenjp2-7-dev \
    libssl-dev \
    libffi-dev \
    libzmq3-dev \
    pybind11-dev \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
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
    Cython \
    keras_applications \
    keras_preprocessing \
    matplot \
    numpy \
    pandas \
    scikit-learn \
    scipy
```

## Install Tensorflow

Since there are Python wheels available for ARM architecture at https://github.com/lhelontra/tensorflow-on-arm/releases we don't need to build it.

```sh
wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v2.4.0/tensorflow-2.4.0-cp37-none-linux_armv7l.whl
pip3 uninstall tensorflow
pip3 install tensorflow-2.4.0-cp37-none-linux_armv7l.whl
```

## Install Jupyter Lab

### Install packages and Python modules

```sh
sudo apt-get install -y --no-install-recommends \
    npm \
    nodejs

sudo npm install -g configurable-http-proxy

sudo pip3 install \
    ipywidgets \
    jupyter \
    jupyterlab
```

### Create a configuration

```sh
jupyter notebook --generate-config
```

### Create a password

```sh
jupyter notebook password
```

### Modify the settings

#### ~/.jupyter/jupyter_notebook_config.py

```py
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
c.NotebookApp.port = 8888
c.NotebookApp.allow_remote_access = True
c.NotebookApp.notebook_dir = '<your_notebook_folder>'
c.NotebookApp.default_url = '/lab'
```

#### ~/.jupyter/jupyter_notebook_config.json

```json
{
    "NotebookApp": {
        "nbserver_extensions": {
            "jupyterlab": true,
            "jupyter_extensions_configurator": true
        }
    }
}
```

### Create the service

Create the service file `/lib/systemd/system/jupyterlab.service`.

```txt
[Unit] 
Description=JupyterLab Service 
After=multi-user.target  

[Service] 
User=<user_name> 
ExecStart=/usr/local/bin/jupyter notebook
Restart=on-failure

[Install] 
WantedBy=multi-user.target
```

Start the service.

```sh
sudo systemctl daemon-reload 
sudo systemctl start jupyterlab
sudo systemctl enable jupyterlab 
sudo systemctl status jupyterlab.service
```

If the status command shows "active (running)" the Jupyter Lab should be reachable by `http://<server_ip_address>:8888/lab`.

## Install R and IRkernel

### Install packages

```sh
sudo apt remove r-base

sudo apt-get install -y --no-install-recommends \
    libbz2-dev \
    libreadline-dev \
    libgit2-dev \
    libxml2-de \
    libpcre3 \
    libpcre3-dev
```

### Build and install binaries

```sh
wget https://ftp.fau.de/cran/src/base/R-4/R-4.1.1.tar.gz
tar -xvf R-4.1.1.tar.gz
rm R-4.1.1.tar.gz
cd R-4.1.1
./configure --with-x=no --disable-java --with-pcre1 --prefix=<r_home_directory>
make && make install
cd ..
rm R-4.1.1
```

### Create soft links

```sh
ln -s <r_home_directory>/bin/R /usr/local/bin/R
ln -s <r_home_directory>/bin/Rscript /usr/local/bin/Rscript
```

### Build and install IRkernel

```R
install.packages('IRkernel', repos='http://cran.rstudio.com/')
IRkernel::installspec()
```

## Use Docker container

The docker container is based on [Debian Buster](https://hub.docker.com/r/arm32v7/debian/) for arm32v7 and installs
 - [TensorFlow](https://www.tensorflow.org/) from [tensorflow-on-arm](https://github.com/lhelontra/tensorflow-on-arm) or [tensorflow-arm-bin](https://github.com/bitsy-ai/tensorflow-arm-bin)
 - [NumPy](https://numpy.org/), [SciPy](https://www.scipy.org/), [Scikit-learn](https://scikit-learn.org/stable/index.html), [Matplotlib](https://matplotlib.org) and [Pandas](https://pandas.pydata.org/)
 - [Tini](https://github.com/krallin/tini) which operates as a process subreaper for jupyter to prevent kernel crashes
 - [Jupyter Notebook](https://jupyter.org/) with [Jupyter Lab](https://jupyterlab.readthedocs.io/en/stable/) as a simple [notebook server](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html) with password protection

### Environment variables

- JUPYTER_PASSWORD = jupyter
- TINI_VERSION = 0.19.0 (used for build only)
- TENSORFLOW_VERSION = 2.4.0 (used for build only)

### Install packages

```sh
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker <user_name>
sudo pip3 install docker-compose
sudo systemctl enable docker
```

### Build and start container

```sh
docker-compose build
docker-compose up -d
```

## Links

https://towardsdatascience.com/setup-your-home-jupyterhub-on-a-raspberry-pi-7ad32e20eed

https://github.com/kleinee/jns

https://github.com/armindocachada/raspberrypi-docker-tensorflow-opencv/blob/main/Dockerfile_tensorflow

https://raspberrypi.stackexchange.com/questions/107483/error-installing-tensorflow-cannot-find-libhdfs-so

https://github.com/kidig/rpi-jupyter-lab

https://github.com/ml-tooling/ml-workspace
