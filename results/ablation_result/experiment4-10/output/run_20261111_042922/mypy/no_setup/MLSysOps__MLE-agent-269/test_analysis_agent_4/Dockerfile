FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install required packages including gnupg and gpg-agent for add-apt-repository key import
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    gnupg \
    gpg-agent \
    wget \
    git \
    curl \
    ca-certificates \
    build-essential \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip for python3.11 and install virtualenv
RUN python3.11 -m pip install --upgrade pip setuptools wheel virtualenv

# Create virtual environment named "testbed"
RUN python3.11 -m virtualenv /opt/testbed

ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Clone repository and checkout specific commit
RUN git clone https://github.com/MLSysOps/MLE-agent.git /testbed
WORKDIR /testbed
RUN git checkout dd7da4e5ac4085fb8324cac3ac0b4c104b9007cb

# Upgrade pip and setuptools inside the virtualenv
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install repository in editable mode so tests run against cloned code
RUN pip install --no-cache-dir -e .

# Install explicit dependencies from requirements_txt_dependencies
RUN pip install --no-cache-dir \
    "py7zr~=0.22.0" \
    "openai~=1.34.0" \
    "pandas~=2.2.2" \
    "tree-sitter==0.21.3" \
    "numexpr~=2.10.1" \
    "bottleneck~=1.4.0" \
    "google-api-python-client~=2.143.0" \
    "google-auth-httplib2~=0.2.0" \
    "google-auth-oauthlib~=1.2.1" \
    "lancedb~=0.15.0" \
    rich \
    click \
    pyyaml \
    kaggle \
    fastapi \
    uvicorn \
    requests \
    chromadb \
    GitPython \
    onnxruntime \
    questionary \
    tavily-python \
    instructor \
    langfuse \
    setuptools

# Reset workdir to /testbed explicitly
WORKDIR /testbed

# Automatically activate virtual environment on bash login
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc