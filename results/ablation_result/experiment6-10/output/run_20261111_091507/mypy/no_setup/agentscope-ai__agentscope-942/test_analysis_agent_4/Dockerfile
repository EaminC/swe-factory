# Use a stable Ubuntu base image with bash and wide package support
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system packages and development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    build-essential \
    ca-certificates \
    locales \
    tzdata \
    python3.10 \
    python3.10-venv \
    python3-pip \
    python3.10-distutils \
    && rm -rf /var/lib/apt/lists/*

# Setup locale to avoid locale warnings
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Upgrade pip
RUN python3.10 -m pip install --upgrade pip setuptools wheel

# Create and activate a virtual environment named testbed
RUN python3.10 -m venv /opt/testbed
ENV PATH="/opt/testbed/bin:$PATH"

# Install pytest and all needed dev dependencies via pip in the venv
# We install the 'agentscope[full]' extra plus testing dependencies as per context
# Using pip install -e . after cloning source code below

# Clone repository and checkout specific commit in one RUN step
RUN git clone -b main https://github.com/agentscope-ai/agentscope.git /testbed && \
    cd /testbed && \
    git reset --hard d662bec3aa81316115336b7eba573c3e33e2930b

WORKDIR /testbed/

# Install project in editable mode with dev dependencies without running tests at install
RUN pip install -q setuptools==78.1.1 wheel==0.45.1
RUN pip install -q -e .[full]
RUN pip install -q pytest pytest-forked sphinx-gallery furo myst-parser matplotlib pymilvus[milvus_lite] ollama>=0.5.4 google-genai Pillow transformers jinja2 ray mem0ai packaging reme-ai>=0.2.0.0 pypdf python-docx nltk qdrant-client==1.15.1

# Echo environment activation for bash ease
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Export environment variables placeholders (keys need to be injected at runtime)
ENV DASHSCOPE_API_KEY=""
ENV GAODE_API_KEY=""

# No ENTRYPOINT or CMD: tests will be triggered externally after container is started or used