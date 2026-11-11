# Base image with bash and Ubuntu 22.04 LTS for stability and compatibility
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including python3.10, pip, git, curl, and other essentials
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    ca-certificates \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set locale (some python packages expect locale to be set)
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install pip for python3.10
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 -

# Use python3.10 as default python and pip3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
RUN update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip 1

# Create and activate a virtual environment named testbed and install dependencies inside it
RUN python -m venv /opt/testbed

# Make sure pip inside venv is updated
RUN /bin/bash -c "source /opt/testbed/bin/activate && python -m pip install --upgrade pip setuptools wheel"

# WORKDIR set to /testbed as requested
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA
ARG REPO=https://github.com/AntonOsika/gpt-engineer.git
ARG COMMIT_SHA=ba00896c5673990923abd0e99dba147938871512

RUN git clone $REPO /testbed && \
    cd /testbed && \
    git checkout $COMMIT_SHA

# Install the project in editable mode with required test dependencies
# Added tabulate explicitly to cover missing dependency from test logs
RUN /bin/bash -c "source /opt/testbed/bin/activate && \
    pip install -e . && \
    pip install pytest==7.3.1 pytest-cov tabulate"

# Setup environment variable template (users must set OPENAI_API_KEY on runtime separately)
ENV OPENAI_API_KEY=""

# Add activation of virtual environment to bashrc for interactive use
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Default shell
SHELL ["/bin/bash", "-c"]