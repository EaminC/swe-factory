FROM --platform=linux/x86_64 ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Add deadsnakes PPA to get python3.11 and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update

# Install system dependencies including python3.11 and its venv and distutils packages
RUN apt-get install -y --no-install-recommends \
    git \
    wget \
    build-essential \
    ca-certificates \
    curl \
    tzdata \
    locales \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    && rm -rf /var/lib/apt/lists/*

# Install pip for python3.11
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 -

# Setup locale and timezone
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create a virtual environment for the testbed
RUN python3.11 -m venv /opt/testbed

ENV PATH="/opt/testbed/bin:$PATH"

# Upgrade pip and setuptools (ensure setuptools minimal version)
RUN pip install --upgrade pip setuptools>=38.6.0

WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA
RUN git clone https://github.com/MLSysOps/MLE-agent.git /testbed && \
    git checkout 38385de9d345570271e1fc92119630fe3e3886dc

# Install dependencies via requirements.txt and install repository in editable mode
RUN pip install -r requirements.txt && \
    pip install -e .

# Source the virtualenv automatically for interactive shells
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc