FROM raspbian/stretch

USER root

WORKDIR /notebooks

# Install packages
RUN apt-get update && apt-get -y install --no-install-recommends \
    gfortran \
    build-essential \
    curl \
    gcc \
    g++ \
    gdown \
    gfortran \
    jupyterlab \
    jupyter-tensorboard \
    libc-ares-dev \
    libopenblas-dev \
    libblas-dev \
    liblapack-dev \
    libatlas-base-dev \
    libhdf5-dev \
    libeigen3-dev \
    libopenjp2-7-dev \
    libzmq3-dev \
    npm \
    nodejs \
    pybind11-dev \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-scipy \
    wget \
    && \
    apt-get clean

# Switch to Python3
RUN pip3 install --upgrade pip \
    && rm /usr/bin/python \
    && ln -s /usr/bin/python3 /usr/bin/python

# Install Python modules
RUN pip3 install \
    keras_applications \
    keras_preprocessing \
    matplot \
    numpy \
    pandas \
    scikit-learn \
    scipy \
    wheel

# Install Tensorflow 2.4.0
RUN wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v2.4.0/tensorflow-2.4.0-cp37-none-linux_armv7l.whl \
    && pip3 install tensorflow-2.4.0-cp37-none-linux_armv7l.whl

# Install Jupyter Tensorboard Extension (requires NodeJs >= 12.0)
#RUN jupyter labextension install jupyterlab_tensorboard

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]
