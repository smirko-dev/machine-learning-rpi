FROM raspbian/stretch

USER root

WORKDIR /root

# Install packages
RUN apt-get update && apt-get -y install --no-install-recommends \
    build-essential \
    cmake \
    curl \
    gcc \
    g++ \
    gdown \
    gfortran \
    jupyterlab \
    jupyter-tensorboard \
    libc-ares-dev \
    libfreetype6-dev \
    libncurses5-dev \
    libopenblas-dev \
    libpng \
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
	ipywidgets \
	jupyter \
	jupyterlab \
    matplot \
    numpy \
    pandas \
    readline \
    scikit-learn \
    scipy \
    wheel

# Configure JupyterLab
RUN jupyter nbextension enable --py widgetsnbextension
RUN jupyter serverextension enable --py jupyterlab
RUN mkdir notebooks
RUN jupyter notebook --generate-config \
	&& sed -i "c.NotebookApp.open_browser/c c.NotebookApp.open_browser = False" /root/.jupyter/jupyter_notebook_config.py \
	&& sed -i "c.NotebookApp.ip/c c.NotebookApp.ip = '*'" /root/.jupyter/jupyter_notebook_config.py
	&& set -i "c.NotebookApp.notebook_dir/c c.NotebookApp.notebook_dir = '/root/notebooks'" /root/.jupyter/jupyter_notebook_config.py
	&& set -i "c.NotebookApp.allow_remote_access/c c.NotebookApp.allow_remote_access = True" /root/.jupyter/jupyter_notebook_config.py

# Install Tensorflow
RUN wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v2.4.0/tensorflow-2.4.0-cp37-none-linux_armv7l.whl \
    && pip3 install tensorflow-2.4.0-cp37-none-linux_armv7l.whl

# Install Tini
ENV TINI_VERSION 0.18.0
ENV CFLAGS="-DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37"
ADD https://github.com/krallin/tini/archives/v${TINI_VERSION}.tar.gz /root/v${TINI_VERSION}.tar.gz
RUN tar zxvf v${TINI_VERSION}.tar.gz \
	&& cd tinit-${TINI_VERSION} \
	&& cmake . \
	&& make \
	&& cp tini /usr/bin/. \
	&& cd .. \
	&& rm -rf "./tini-${TINI_VERSION}" \
	&& rm "./v${TINI_VERSION}.tar.gz"

VOLUME /root/notebooks

ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 8888

CMD ["jupyter", "lab","--allow-root"]
