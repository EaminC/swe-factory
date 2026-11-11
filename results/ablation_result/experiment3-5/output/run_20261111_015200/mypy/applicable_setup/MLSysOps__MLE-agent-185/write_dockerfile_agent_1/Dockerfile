FROM --platform=linux/x86_64 ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    curl \
    wget \
    build-essential \
    ca-certificates \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Set python3 to point to python3.11 and install pip for python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 -

# Create workdir
WORKDIR /testbed/

# Clone the repository and checkout the specified commit
RUN git clone https://github.com/MLSysOps/MLE-agent.git /testbed \
    && git reset --hard 8109d8b905bb4aac4de6258516a966abaf2147f5

# Install python packages and dependencies inside a venv for isolation
RUN python3 -m venv /testbed/testbed-venv

# Activate venv and install the project dependencies in development mode
RUN source /testbed/testbed-venv/bin/activate \
    && pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir openai~=1.34.0 pandas~=2.2.2 numexpr~=2.10.1 bottleneck~=1.4.0 google-api-python-client~=2.143.0 google-auth-httplib2~=0.2.0 google-auth-oauthlib~=1.2.1 rich click pyyaml fastapi uvicorn requests chromadb onnxruntime questionary tavily-python instructor setuptools \
    && pip install --no-cache-dir -e .

# Add command to activate the virtual environment automatically in bash shell
RUN echo "source /testbed/testbed-venv/bin/activate" >> /root/.bashrc
ENV PATH="/testbed/testbed-venv/bin:$PATH"