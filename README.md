# Machine Learning with JupyterLab on a Raspberry Pi

## Setup environment

### Install packages

```sh
sudo apt-get update && sudo apt-get upgrade

apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    gdown \
    gfortran \
    libc-ares-dev \
    libopenblas-dev \
    libblas-dev \
    liblapack-dev \
    libatlas-base-dev \
    libhdf5-dev \
    libeigen3-dev \
    libopenjp2-7-dev \
    libzmq3-dev \
    pybind11-dev \
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
    scikit-learn \
    scipy \
    wheel
```

### Install Tensorflow

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

## Install R-3.6.0 and the IRkernel

### Install packages

```sh
sudo apt remove r-base

sudo apt-get install -y --no-install-recommends \
    libbz2-dev \
    libreadline-de
```

### Build and install binaries

```sh
wget http://mirrors.psu.ac.th/pub/cran/src/base/R-3/R-3.6.3.tar.gz
tar -xvf R-3.6.3.tar.gz
rm R-3.6.3.tar.gz
cd R-3.6.3
./configure --with-x=no --disable-java --prefix=<r_home_directory>
make && make install
cd ..
rm R-3.6.3
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

## Links

https://towardsdatascience.com/setup-your-home-jupyterhub-on-a-raspberry-pi-7ad32e20eed

https://github.com/kleinee/jns

https://github.com/armindocachada/raspberrypi-docker-tensorflow-opencv/blob/main/Dockerfile_tensorflow

https://raspberrypi.stackexchange.com/questions/107483/error-installing-tensorflow-cannot-find-libhdfs-so

https://github.com/ml-tooling/ml-workspace
