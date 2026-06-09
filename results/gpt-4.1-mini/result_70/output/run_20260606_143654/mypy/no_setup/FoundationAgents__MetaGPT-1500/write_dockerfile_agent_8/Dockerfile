# Use Ubuntu 22.04 LTS base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Set bash as default shell
SHELL ["/bin/bash", "-c"]

# Install system dependencies and development tools, specify python3.11 to address paddlepaddle compatibility
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ca-certificates \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3-pip \
    python3-distutils \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set up locale (optional but recommended)
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Setup python alternatives explicitly for python3.11
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Install Node.js v20.x from NodeSource repository to satisfy engine requirements
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

# Install playwright and mermaid-cli globally via npm in two separate RUN steps to isolate layers
RUN npm install -g playwright @mermaid-js/mermaid-cli

RUN playwright install --with-deps

# Create virtual environment named 'testbed' with python3.11
RUN python -m venv /opt/testbed

# Activate virtual environment and upgrade pip, setuptools, wheel
RUN /bin/bash -c "source /opt/testbed/bin/activate && pip install --upgrade pip setuptools wheel"

# Set environment variables for later stages
ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Clone target repository and checkout specific commit
RUN git clone https://github.com/FoundationAgents/MetaGPT.git /testbed && \
    cd /testbed && \
    git reset --hard 4c55a976c677202cdca6a51da8dbd326de650f9c && \
    chmod -R 777 /testbed

WORKDIR /testbed

# Install python dependencies and the repository itself in editable mode with tests extras
RUN /bin/bash -c "source /opt/testbed/bin/activate && \
    pip install -e '.[test]'"

# Add configuration environment variable if needed (as per config file note)
ENV METAGPT_CONFIG_FILE=~/.metagpt/config2.yaml

# Provide default shell entrypoint for interactive use
CMD ["/bin/bash"]