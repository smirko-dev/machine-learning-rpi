# Machine Learning with JupyterLab on a Raspberry Pi

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

If the status command shows "active (running)" the Jupyter Lab should be available `http://<server_ip_address>:8888/lab`.
