# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation. Installs essential tools and libraries required for development and runtime (Required)
RUN apt-get update && apt-get install -y \
    git \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    wget \
    curl \
    build-essential \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install pip for python3.11
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 -

# Set locales and timezone
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create and activate a virtual environment for the tests
RUN python3.11 -m venv /opt/testbed

ENV PATH="/opt/testbed/bin:$PATH"

# Set default workdir to testbed (will clone repo here)
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA
ARG REPO=https://github.com/MLSysOps/MLE-agent.git
ARG COMMIT_SHA=38385de9d345570271e1fc92119630fe3e3886dc

RUN git clone "$REPO" . \
    && git reset --hard "$COMMIT_SHA"

# Upgrade pip and install dependencies from requirements.txt and install package in dev mode
RUN pip install --upgrade pip \
    && pip install -r requirements.txt \
    && pip install -e .

# Add bashrc to autoactivate the environment when starting a shell
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc