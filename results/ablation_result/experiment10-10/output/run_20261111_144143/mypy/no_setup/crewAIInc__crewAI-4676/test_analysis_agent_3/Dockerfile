FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies and build tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    software-properties-common \
    locales \
    locales-all \
    tzdata \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    rustc \
    cargo \
    && rm -rf /var/lib/apt/lists/*

# Setup alternatives for python3 and pip to python3.10 version
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
 && python3 -m pip install --upgrade pip setuptools wheel

# Install UV toolchain
RUN pip3 install --no-cache-dir uv==0.8.4

WORKDIR /testbed/

# Clone the targeted repo and checkout specific commit
RUN git clone https://github.com/crewAIInc/crewAI . && \
    git reset --hard e7f17d228429e7c9dc997d1ff0fd19a7c9078d9b

# Create Python virtual environment named 'testbed' and activate it, then install dependencies via uv toolchain commands
RUN python3 -m venv testbed
ENV VIRTUAL_ENV=/testbed/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN uv pip install --upgrade pip setuptools wheel

# Install the package itself in editable/development mode WITH tools extras
RUN uv pip install 'crewai[tools]'

# Lock dependencies (ensure lockfile exists)
RUN uv lock

# Sync dependencies to ensure all locked dependencies installed
RUN uv sync

# Disable telemetry explicitly by env variable
ENV OTEL_SDK_DISABLED=true

# Set default working directory with virtualenv activated
WORKDIR /testbed/

# Keep bash as default shell with conda-like environment activation on shell start
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc