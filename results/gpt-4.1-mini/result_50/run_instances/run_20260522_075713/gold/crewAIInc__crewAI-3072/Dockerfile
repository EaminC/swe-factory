FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Explicitly update and refresh ca-certificates first to avoid cached broken layers
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && update-ca-certificates && rm -rf /var/lib/apt/lists/*

# Install all required system dependencies in one step with cleanup to minimize layer size
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    wget \
    software-properties-common \
    pkg-config \
    libssl-dev \
    libffi-dev \
    python3.10 \
    python3.10-distutils \
    python3.10-venv \
    python3.10-dev \
    rustc \
    cargo \
    && rm -rf /var/lib/apt/lists/*

# Set python3.10 as default python (stable release in Ubuntu 22.04)
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
 && python --version

# Install pip for python3.10 separately, with retries to improve network reliability
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

# Create a virtual environment named testbed
RUN python3.10 -m venv /opt/testbed

# Clone the repository and checkout the specific commit atomically
WORKDIR /testbed
RUN git clone https://github.com/crewAIInc/crewAI /testbed && \
    cd /testbed && \
    git reset --hard b09796cd3ff4d5ec3c1870ca6c516b7981d6778a

# Install the repo in editable mode and upgrade tooling inside the virtual environment
# uv will be installed separately during runtime according to collected info, so install only project dependencies here
RUN /bin/bash -c "source /opt/testbed/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -e ."

# Configure bash to automatically activate virtual environment on login
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Set working directory to /testbed for convenience
WORKDIR /testbed