# Base image specification with bash shell included, Ubuntu 22.04 for stability and compatibility
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, curl, python3.11 and other essentials
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    wget \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Configure locale and timezone
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Upgrade pip and install uv tool (required dependency management tool)
RUN python3.11 -m pip install --upgrade pip
RUN python3.11 -m pip install uv

# Set WORKDIR
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    cd /testbed && \
    git reset --hard 73f328860b4a477a6d3736e646783d7493841cb4 && \
    git remote remove origin

# Setup virtual environment with uv and sync dependencies
RUN python3.11 -m venv /testbed/testbed_venv
ENV PATH="/testbed/testbed_venv/bin:$PATH"

RUN /bin/bash -c "source /testbed/testbed_venv/bin/activate && \
    uv sync && \
    pip install -e . && \
    pip install 'crewai[tools]'"

# Set default environment variables (empty by default, but documented)
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED="true"

# Add activation of venv to bashrc for interactive sessions inside container
RUN echo "source /testbed/testbed_venv/bin/activate" >> /root/.bashrc