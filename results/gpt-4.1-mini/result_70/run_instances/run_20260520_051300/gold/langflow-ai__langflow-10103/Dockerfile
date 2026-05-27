# Use an Ubuntu base image with bash and stable support
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and basic utilities
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set locale to avoid locale-related warnings
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install python3.10 as default python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# Upgrade pip to ensure latest packaging support
RUN python3 -m pip install --upgrade pip

# Install 'uv' python package (must be >=0.4) as per environment requirements
RUN python3 -m pip install uv>=0.4

# Install Node.js v22.12 LTS (npm included) as required by the development environment
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@10.9.0 \
    && npm --version \
    && node --version

# Install make tool for orchestration early to avoid later layer split
RUN apt-get update && apt-get install -y make && rm -rf /var/lib/apt/lists/*

# Create and activate virtual environment named 'testbed'
RUN python3 -m venv /opt/venvs/testbed
ENV VIRTUAL_ENV=/opt/venvs/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Upgrade pip inside the virtual environment
RUN pip install --upgrade pip setuptools wheel

WORKDIR /testbed

# Clone the langflow-ai/langflow repository and checkout the specified commit
RUN git clone https://github.com/langflow-ai/langflow.git . \
    && git reset --hard 58efe809d4dad3decc833afd2f29b9a1038f6d5c

# Install wheel and build dependencies before attempting package installation to reduce backtracking
RUN pip install wheel build

# Install backend dependencies using the recommended make orchestration:
# Since runner will run tests separately, install the local package in editable mode
# Installing the package without dependencies first reduces resolver load
RUN pip install --no-deps -e .

# Install backend dependencies via make which will install dependencies as per DEVELOPMENT.md
RUN make install_backend

# Install frontend dependencies via make as specified in DEVELOPMENT.md
RUN make install_frontend

# Now install package dependencies explicitly to lock versions as per locked files
# Using uv sync if it manages dependencies and installs from uv.lock (preferred)
RUN uv sync

# Set working directory explicitly
WORKDIR /testbed

# Add source activation to bashrc for convenience in interactive sessions
RUN echo "source $VIRTUAL_ENV/bin/activate" >> /root/.bashrc