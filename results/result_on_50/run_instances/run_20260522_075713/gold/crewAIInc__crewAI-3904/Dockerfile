# Use Ubuntu 22.04 LTS as base for compatibility and stability
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including Python 3.10, git, build tools, rust (needed for some wheels), pip, virtualenv support
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    rustc \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to latest stable release using python3.10 executable to avoid relying on venv before creation
RUN python3.10 -m pip install --upgrade pip

# Create Python virtual environment named 'testbed'
RUN python3.10 -m venv /opt/testbed

# Upgrade pip inside virtual environment
RUN /opt/testbed/bin/python -m pip install --upgrade pip

# Set PATH to prioritize virtual environment's bin directory
ENV PATH="/opt/testbed/bin:$PATH"
ENV SHELL=/bin/bash

# Clone the repository and checkout the specific commit SHA
RUN git clone https://github.com/crewAIInc/crewAI /testbed && \
    cd /testbed && \
    git reset --hard 528d81226361be0f87c9e077ed0d3eb28243120f && \
    git remote remove origin

WORKDIR /testbed

# Install key dependencies in the virtual environment:
#   - Install crewai package in editable mode
#   - Install optional extras tools and embeddings per context retrieval
#   - Install pytest explicitly as the testing framework
RUN pip install 'crewai[tools]' 'crewai[embeddings]' && \
    pip install -e . && \
    pip install pytest tiktoken --prefer-binary

# Set environment variables required by the project
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED="true"
ENV share_crew="True"

# Add helper command to activate the virtual environment on container start
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# The container is now ready with all dependencies to run tests with 'uv run pytest .' externally