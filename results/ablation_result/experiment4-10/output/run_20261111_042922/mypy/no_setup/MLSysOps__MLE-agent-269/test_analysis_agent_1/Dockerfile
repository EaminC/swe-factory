FROM --platform=linux/x86_64 ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and Python 3.11 from deadsnakes PPA
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    git \
    curl \
    ca-certificates \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip for python3.11 and install virtualenv
RUN python3.11 -m pip install --upgrade pip setuptools wheel virtualenv

# Create and activate virtual environment named "testbed"
RUN python3.11 -m virtualenv /opt/testbed

ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Clone repository and checkout specific commit
RUN git clone https://github.com/MLSysOps/MLE-agent.git /testbed
WORKDIR /testbed
RUN git checkout dd7da4e5ac4085fb8324cac3ac0b4c104b9007cb

# Install package dependencies
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install dependencies from the repository itself in development mode
RUN pip install --no-cache-dir -e .

# Install requirements.txt dependencies individually because they are listed by context as needed
# We will install all dependencies mentioned from requirements_txt_dependencies via pip install
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

# Reset workdir explicitly as required
WORKDIR /testbed

# Add bashrc to activate virtual environment automatically on interactive shell
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc