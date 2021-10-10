FROM raspian/stretch

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
	libc-ares-dev \
	libopenblas-dev \
	libblas-dev \
	liblapack-dev \
	libatlas-base-dev \
	libhdf5-dev \
	libeigen3-dev \
	libopenjp2-7-dev \
	libfreetype6-dev \
	libncurses5-dev \
	libpng \
	libzmq-dev \
	libzmq3-dev \
	pybind11-dev \
	python3 \
	python3-dev \
	python3-pip \
	python3-scipy \
	python3-setuptools \
	tini \
	wget \
	&& \
	apt-get clean

# Switch to Python3
RUN pip3 install --upgrade pip \
	&& rm /usr/bin/python \
	&& ln -s /usr/bin/python3 /usr/bin/python

# Install Python modules
RUN pip3 install \
	ipywidgets \
	jupyter \
	jupyterlab \
	keras_applications \
	keras_preprocessing \
	matplot \
	numpy \
	pandas \
	readline \
	scikit-learn \
	scipy \
	wheel

# Install Tensorflow
RUN wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v2.4.0/tensorflow-2.4.0-cp37-none-linux_armv7l.whl \
	&& pip3 uninstall tensorflow \
	&& pip3 install tensorflow-2.4.0-cp37-none-linux_armv7l.whl

# Configure JupyterLab
RUN jupyter nbextension enable --py widgetsnbextension
RUN jupyter serverextension enable --py jupyterlab
RUN mkdir notebooks
RUN jupyter notebook --generate-config \
	&& sed -i "c.NotebookApp.open_browser/c c.NotebookApp.open_browser = False" /root/.jupyter/jupyter_notebook_config.py \
	&& sed -i "c.NotebookApp.ip/c c.NotebookApp.ip = '*'" /root/.jupyter/jupyter_notebook_config.py
	&& set -i "c.NotebookApp.notebook_dir/c c.NotebookApp.notebook_dir = '/root/notebooks'" /root/.jupyter/jupyter_notebook_config.py
	&& set -i "c.NotebookApp.allow_remote_access/c c.NotebookApp.allow_remote_access = True" /root/.jupyter/jupyter_notebook_config.py

# Add volume for notebooks
VOLUME /root/notebooks

# Run Tini. It operates as a process subreaper for Jupyter. This prevents kernel crashes.
ENTRYPOINT ["/usr/bin/tini", "--"]

# Expose port
EXPOSE 8888

# Start JupyterLab
CMD ["jupyter", "lab", "--allow-root"]
