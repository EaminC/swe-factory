# Base image specification. Defines the foundation OS and architecture for the container (Required)
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ARG COMMIT_SHA=9dffd42e6d3b81973e6b4e76fdb906dae649e04a
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# System dependencies installation. Install essential tools and libraries required for development and runtime.
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
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin

# Create Python virtual environment
RUN python3 -m venv testbed_venv

# Install project dependencies inside virtual environment and install project in editable mode
RUN /bin/bash -c "\
    source /testbed/testbed_venv/bin/activate && \
    pip install --upgrade pip && \
    pip install 'pydantic>=2.4.2' \
                'openai>=1.13.3' \
                'litellm==1.60.2' \
                'instructor>=1.3.3' \
                'pdfplumber>=0.11.4' \
                'regex>=2024.9.11' \
                'opentelemetry-api>=1.22.0' \
                'opentelemetry-sdk>=1.22.0' \
                'chromadb>=0.5.23' \
                'auth0-python>=4.7.1' \
                'python-dotenv>=1.0.0' \
                'uv>=0.4.25' && \
    pip install tiktoken --prefer-binary && \
    pip install -e . \
"

# Add activation command to root user bashrc for convenience
RUN echo "source /testbed/testbed_venv/bin/activate" >> /root/.bashrc

# Set default working directory
WORKDIR /testbed/