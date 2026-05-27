# Use Ubuntu 22.04 as base image since it includes Python 3.10 by default, avoiding PPA issues
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: python3.10, venv, dev packages, git, curl, build essentials, rust, cargo, and locales
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3-pip \
    rustc \
    cargo \
    locales \
    locales-all \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, and wheel for Python 3.10
RUN python3.10 -m pip install --upgrade pip setuptools wheel

# Install uv tool globally via pip (required for environment management)
RUN python3.10 -m pip install uv

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specified commit
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed/ \
 && cd /testbed/ \
 && git reset --hard 4d8eec96e8432eda570207a601655ec29e9d1d6e \
 && git remote remove origin

# Create uv virtual environment with a distinct venv name to avoid "testbed" folder conflict
RUN /bin/bash -c "\
    uv venv .venv \
"

# Ensure the virtual environment auto-activates on shell start
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Set environment variable placeholders to be overridden at runtime
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED="true"

# Use bash as default shell
CMD ["/bin/bash"]