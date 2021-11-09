#FROM arm32v7/ubuntu:bionic
FROM arm32v7/debian:buster

USER root

WORKDIR /root

# Install packages
RUN apt-get update && apt-get -y install --no-install-recommends \
	build-essential \
	gfortran \
	libatlas-base-dev \
	libc-ares-dev \
	libcurl4-openssl-dev \
	libbz2-dev \
	libeigen3-dev \
	libffi-dev \
	libfreetype6-dev \
	libgit2-dev \
	libhdf5-103 \
	libhdf5-dev \
	libhdf5-serial-dev \
	liblzma-dev \
	libopenmpi-dev \
	libpng-dev \
	libpcre3 \
	libpcre3-dev \
	libreadline-dev \
	libxml2-dev \
	openmpi-bin \
	openssl \
	python3 \
	python3-dev \
	python3-pip \
	python3-setuptools \
	python3-wheel \
	&& \
	apt-get clean

# Switch to Python 3
RUN rm -f /usr/bin/python \
	&& ln -s /usr/bin/python3 /usr/bin/python \
	&& python -m pip install --upgrade pip

# Install Python modules
RUN python -m pip install Cython==0.29.24
RUN python -m pip install numpy==1.19.5
RUN python -m pip install matplotlib==3.0.2
RUN python -m pip install scikit-learn==0.20.2
RUN python -m pip install pandas==1.0

# Install Tini
ENV TINI_VERSION 0.19.0
ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-armhf /usr/bin/tini
RUN chmod +x /usr/bin/tini

# Install Tensorflow
ENV TENSORFLOW_VERSION 2.4.0
ADD https://github.com/bitsy-ai/tensorflow-arm-bin/releases/download/v${TENSORFLOW_VERSION}/tensorflow-${TENSORFLOW_VERSION}-cp37-none-linux_armv7l.whl .
RUN python -m pip install \
	h5py==2.10.0 \
	keras_applications==1.0.8 --no-deps \
	keras_preprocessing==1.1.0 --no-deps
RUN python -m pip uninstall tensorflow \
	&& python -m pip install tensorflow-${TENSORFLOW_VERSION}-cp37-none-linux_armv7l.whl

# Install and configure Jupyter
ENV JUPYTER_PASSWORD jupyter
RUN python -m pip install \
	notebook==6.4.5 \
	jupyterlab==3.2.1
RUN jupyter serverextension enable --py jupyterlab
RUN mkdir notebooks
RUN jupyter notebook --generate-config
RUN sed -i "/c.NotebookApp.open_browser/c c.NotebookApp.open_browser = False" /root/.jupyter/jupyter_notebook_config.py \
	&& sed -i "/c.NotebookApp.ip/c c.NotebookApp.ip = '*'" /root/.jupyter/jupyter_notebook_config.py \
	&& sed -i "/c.NotebookApp.notebook_dir/c c.NotebookApp.notebook_dir = '/root/notebooks'" /root/.jupyter/jupyter_notebook_config.py \
	&& sed -i "/c.NotebookApp.allow_remote_access/c c.NotebookApp.allow_remote_access = True" /root/.jupyter/jupyter_notebook_config.py \
	&& sed -i "/c.NotebookApp.token/c c.NotebookApp.token = ''" /root/.jupyter/jupyter_notebook_config.py \
	&& sed -i "/c.NotebookApp.password_required/c c.NotebookApp.password_required = True" /root/.jupyter/jupyter_notebook_config.py \
	&& python -c "from notebook.auth import passwd; print(passwd('${JUPYTER_PASSWORD}', 'sha1'));" >> password \
	&& sed -i "/c.NotebookApp.password/c c.NotebookApp.password = '`cat password`'" /root/.jupyter/jupyter_notebook_config.py \
	&& rm -f password

# Install R
ENV R_VERSION 3.3.3
ADD https://ftp.fau.de/cran/src/base/R-3/R-${R_VERSION}.tar.gz .
RUN apt-get remove r-base
RUN tar -xvf R-${R_VERSION}.tar.gz \
	&& rm R-${R_VERSION}.tar.gz \
	&& cd R-${R_VERSION} \
	&& ./configure --with-x=no --disable-java --with-pcre1 --prefix=/root/R \
	&& make && make install \
	&& cd .. \
	&& rm -rf R-${R_VERSION} \
	&& ln -s /root/R/bin/R /usr/bin/R \
	&& ln -s /root/R/bin/Rscript /usr/bin/Rscript

COPY ./install.R /root
RUN Rscript /root/install.R

# Add volume for notebooks
VOLUME /root/notebooks

# Run Tini. It operates as a process subreaper for Jupyter. This prevents kernel crashes.
ENTRYPOINT ["/usr/bin/tini", "--"]

# Expose port
EXPOSE 8888

# Start Jupyter
CMD ["jupyter", "lab", "--allow-root"]
