# Base image specification with platform and OS version
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ARG COMMIT_SHA=40a441f30eebce88b928db875e4309b892a9ac11
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including python3.11, rust (for building tiktoken), git, build essentials, etc.
RUN apt update && apt install -y \
    git \
    wget \
    curl \
    build-essential \
    libffi-dev \
    libssl-dev \
    locales-all \
    tzdata \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    rustc \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && python3 -m pip install --upgrade pip \
    && rm -rf /var/lib/apt/lists/*

# Install Hatchling build system globally since the project uses it
RUN python3 -m pip install hatchling

# Setup working directory
WORKDIR /testbed/

# Clone target repository, checkout specific commit SHA, and remove origin remote for reproducibility
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed \
    && cd /testbed \
    && git reset --hard ${COMMIT_SHA} \
    && git remote remove origin

# Create Python virtual environment
RUN python3 -m venv /testbed/testbed_venv

# Install project core and optional dependencies inside virtual environment and install project in editable mode
RUN /bin/bash -c "\
    source /testbed/testbed_venv/bin/activate && \
    pip install --upgrade pip && \
    pip install 'pydantic>=2.4.2' \
                'openai>=1.13.3' \
                'litellm==1.60.2' \
                'instructor>=1.3.3' \
                'pdfplumber>=0.11.4' \
                'regex>=2024.9.11' \
                'opentelemetry-api>=1.30.0' \
                'opentelemetry-sdk>=1.30.0' \
                'opentelemetry-exporter-otlp-proto-http>=1.30.0' \
                'chromadb>=0.5.23' \
                'openpyxl>=3.1.5' \
                'pyvis>=0.3.2' \
                'auth0-python>=4.7.1' \
                'python-dotenv>=1.0.0' \
                'click>=8.1.7' \
                'appdirs>=1.4.4' \
                'jsonref>=1.1.0' \
                'json-repair>=0.25.2' \
                'uv>=0.4.25' \
                'tomli-w>=1.1.0' \
                'tomli>=2.0.2' \
                'blinker>=1.9.0' \
                'json5>=0.10.0' && \
    pip install 'crewai[mem0]' && \
    pip install tiktoken --prefer-binary && \
    pip install -e . \
"

# Add activation command to root user bashrc for convenience
RUN echo "source /testbed/testbed_venv/bin/activate" >> /root/.bashrc

# Set default working directory
WORKDIR /testbed/