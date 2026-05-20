FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

# Install system dependencies in smaller chunks to reduce memory load
RUN apt-get update && apt-get install -y git curl build-essential \
    && apt-get install -y python3 python3-pip python3-venv python3-setuptools python3-tk \
    && apt-get install -y locales locales-all tzdata \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for locale and timezone
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TZ=Etc/UTC

# Ensure python and pip point to python3 and pip3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
 && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Create virtual environment, upgrade pip/setuptools, clone repo and install dependencies all in one layer
RUN python -m venv /opt/testbed-venv \
 && /bin/bash -c "source /opt/testbed-venv/bin/activate && pip install --upgrade pip setuptools" \
 && git clone https://github.com/AntonOsika/gpt-engineer.git /testbed/ \
 && cd /testbed/ \
 && git reset --hard 7dac88a3f8e8c0610e9e3189c867b19d055dab2d \
 && /bin/bash -c "source /opt/testbed-venv/bin/activate && pip install -e . pytest==7.3.1"

# Set working directory after cloning
WORKDIR /testbed/

# Add virtual environment activation to root user's bashrc for convenience
RUN echo "source /opt/testbed-venv/bin/activate" >> /root/.bashrc

# Set default shell to bash
SHELL ["/bin/bash", "-c"]