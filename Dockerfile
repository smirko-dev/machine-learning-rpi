FROM arm32v7/ubuntu:bionic

USER root

WORKDIR /root

# Install packages
RUN apt-get update && apt-get -y install --no-install-recommends \
	build-essential \
	libffi-dev \
	openssl \
	python3 \
	python3-dev \
	python3-pip \
	python3-setuptools \
	wget \
	&& \
	apt-get clean

# Switch to Python3
RUN pip3 install --upgrade pip \
	&& rm -f /usr/bin/python \
	&& ln -s /usr/bin/python3 /usr/bin/python

# Install Python modules
RUN pip3 install \
	jupyterlab==3.1.13 \
	wheel

# Add Tini
ENV TINI_VERSION 0.19.0
ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-armhf /usr/bin/tini
RUN chmod +x /usr/bin/tini

# Install Tensorflow
#ENV TENSORFLOW_VERSION 2.4.0
#RUN wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v2.4.0/tensorflow-${TENSORFLOW_VERSION}-cp37-none-linux_armv7l.whl \
#	&& pip3 uninstall tensorflow \
#	&& pip3 install tensorflow-${TENSORFLOW_VERSION}-cp37-none-linux_armv7l.whl

# Configure JupyterLab
ENV JUPYTER_PASSWORD jupyter
RUN jupyter serverextension enable --py jupyterlab
RUN mkdir notebooks
RUN jupyter notebook --generate-config
RUN sed -i "/c.NotebookApp.open_browser/c c.NotebookApp.open_browser = False" /root/.jupyter/jupyter_notebook_config.py \
	&& sed -i "/c.NotebookApp.ip/c c.NotebookApp.ip = '*'" /root/.jupyter/jupyter_notebook_config.py \
	&& set -i "/c.NotebookApp.notebook_dir/c c.NotebookApp.notebook_dir = '/root/notebooks'" /root/.jupyter/jupyter_notebook_config.py \
	&& set -i "/c.NotebookApp.allow_remote_access/c c.NotebookApp.allow_remote_access = True" /root/.jupyter/jupyter_notebook_config.py \
	&& set -i "/c.NotebookApp.token/c c.NotebookApp.token = ''" /root/.jupyter/jupyter_notebook_config.py \
	&& set -i "/c.NotebookApp.password_required/c c.NotebookApp.password_required = True" /root/.jupyter/jupyter_notebook_config.py \
	&& python -c "from notebook.auth import passwd; print(passwd('${JUPYTER_PASSWORD}'));" >> password \
	&& set -i "/c.NotebookApp.password/c c.NotebookApp.password = 'sha1:`cat password`'" /root/.jupyter/jupyter_notebook_config.py \
	&& rm -f password

# Add volume for notebooks
VOLUME /root/notebooks

# Run Tini. It operates as a process subreaper for Jupyter. This prevents kernel crashes.
ENTRYPOINT ["/usr/bin/tini", "--"]

# Expose port
EXPOSE 8888

# Start JupyterLab
CMD ["jupyter", "lab", "--allow-root"]
