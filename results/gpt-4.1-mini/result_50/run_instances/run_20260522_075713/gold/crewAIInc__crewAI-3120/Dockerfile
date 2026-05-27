# Use Ubuntu 22.04 as base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, curl, build tools, python 3.11, pip and libs needed for python packages and runtime
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    ca-certificates \
    locales-all \
    tzdata \
    rustc \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to the latest version for Python 3.11
RUN python3.11 -m pip install --no-cache-dir --upgrade pip

# Install Hatchling build system globally (required by project packaging)
RUN python3.11 -m pip install hatchling

# Set working directory to /testbed
WORKDIR /testbed

# Clone the repository, checkout to the requested commit SHA, and remove origin for reproducibility
ARG COMMIT_SHA=eec1262d4fb9dc3ad700d18585a36ae30c860562
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin

# Create Python virtual environment inside the repo directory
RUN python3.11 -m venv /testbed/testbed_venv

# Install project dependencies, tools, and optional extras inside the virtual environment,
# and install the project in editable mode to ensure local source is authoritative
RUN /bin/bash -c "\
    source /testbed/testbed_venv/bin/activate && \
    pip install --upgrade pip && \
    pip install 'pydantic>=2.4.2' 'openai>=1.13.3' 'litellm==1.72.6' 'onnxruntime==1.22.0' 'python-dotenv>=1.0.0' 'uv>=0.4.25' && \
    pip install 'crewai[tools]' 'crewai[embeddings]' && \
    pip install -e . && \
    pip install pysqlite3-binary pytest pytest-asyncio pytest-subprocess pytest-recording pytest-randomly pytest-timeout pytest-xdist pytest-split mypy ruff pre-commit Pillow cairosvg"

# Ensure bash activates virtual environment by default in interactive sessions
RUN echo "source /testbed/testbed_venv/bin/activate" >> /root/.bashrc

# Set environment variables defaults to be overridden by test runtime
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED="true"

# Explicitly set bash shell as default
SHELL ["/bin/bash", "-c"]