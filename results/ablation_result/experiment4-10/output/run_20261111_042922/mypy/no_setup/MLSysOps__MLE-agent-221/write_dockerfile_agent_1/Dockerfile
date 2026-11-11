FROM --platform=linux/x86_64 ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, Python 3.11, pip, build essentials and other required tools
RUN apt-get update && apt-get install -y \
    software-properties-common \
    git \
    wget \
    build-essential \
    curl \
    ca-certificates \
    tzdata \
    locales \
    libffi-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install pip for python3.11
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# Create a virtual environment named testbed
RUN python3.11 -m venv /opt/testbed

# Add virtualenv python and pip to PATH
ENV PATH="/opt/testbed/bin:$PATH"

# Upgrade pip in virtualenv
RUN pip install --upgrade pip setuptools

WORKDIR /testbed/

# Clone the repository and checkout the specified commit SHA
RUN git clone https://github.com/MLSysOps/MLE-agent.git /testbed && \
    cd /testbed && \
    git checkout 1b637bed35ef1171f3eb11395c8a5ad2bd8c15b8

# Install the repository dependencies and install in editable mode
RUN pip install --no-cache-dir -e . 

# Expose shell environment with virtualenv activated by default
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc