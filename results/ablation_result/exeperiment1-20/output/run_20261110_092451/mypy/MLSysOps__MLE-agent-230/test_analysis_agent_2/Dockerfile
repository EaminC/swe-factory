# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Add deadsnakes PPA to get python3.11 packages, install system dependencies
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    libffi-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Configure locales and timezone
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Make python3 point to python3.11 and upgrade pip/setuptools/wheel
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    python3 -m pip install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /testbed/

# Clone repo and checkout specific commit
RUN git clone https://github.com/MLSysOps/MLE-agent /testbed/ && \
    cd /testbed/ && \
    git checkout 985c24e1b2b8e9463aacfbeb2c8a47f27fa4523c

# Create virtual environment
RUN python3 -m venv /testbed/testbed-venv

# Activate virtual environment and install pinned and unpinned dependencies and the package itself in editable mode
RUN /bin/bash -c "source /testbed/testbed-venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install 'openai~=1.34.0' 'pandas~=2.2.2' 'numexpr~=2.10.1' 'bottleneck~=1.4.0' 'google-api-python-client~=2.143.0' 'google-auth-httplib2~=0.2.0' 'google-auth-oauthlib~=1.2.1' && \
    pip install rich click pyyaml fastapi uvicorn requests chromadb GitPython onnxruntime questionary tavily-python instructor langfuse setuptools && \
    pip install -e ."

# Add virtual environment activation to bashrc for convenience
RUN echo "source /testbed/testbed-venv/bin/activate" >> /root/.bashrc