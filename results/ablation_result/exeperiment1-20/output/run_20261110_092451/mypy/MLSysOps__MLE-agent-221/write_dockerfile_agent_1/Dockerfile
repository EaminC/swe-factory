# Base image specification with Ubuntu 22.04 and bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system dependencies and Python 3.11 with pip
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    locales \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Configure python3 alias to point to python3.11, and upgrade pip
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
 && python3 -m pip install --upgrade pip setuptools>=38.6.0 wheel

# Create and activate a Python virtual environment named testbed
RUN python3 -m venv /opt/testbed

ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Upgrade pip inside the venv and install mle-agent and its dependencies
RUN pip install --upgrade pip setuptools>=38.6.0

WORKDIR /testbed/

# Clone the target repository and checkout the specific commit
RUN git clone https://github.com/MLSysOps/MLE-agent.git /testbed && \
    cd /testbed && \
    git reset --hard 1b637bed35ef1171f3eb11395c8a5ad2bd8c15b8

# Install dependencies:
# - Install mle-agent package itself in editable mode
# - Install pinned and unversioned dependencies as per context info
RUN pip install mle-agent -U

RUN pip install -e .

# Install pinned dependencies with approximate versions
RUN pip install "openai~=1.34.0" "pandas~=2.2.2" "numexpr~=2.10.1" "bottleneck~=1.4.0" \
    "google-api-python-client~=2.143.0" "google-auth-httplib2~=0.2.0" "google-auth-oauthlib~=1.2.1"

# Install unversioned dependencies
RUN pip install rich click pyyaml fastapi uvicorn requests chromadb onnxruntime \
    questionary tavily-python instructor langfuse setuptools

# Fix permissions for all users
RUN chmod -R a+rwx /testbed /opt/testbed

# Add activate command to bashrc for convenience
RUN echo "source /opt/testbed/bin/activate" >> ~/.bashrc