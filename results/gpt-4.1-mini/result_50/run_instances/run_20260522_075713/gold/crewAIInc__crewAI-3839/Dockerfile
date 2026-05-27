# Base image specification. Ubuntu 22.04 with amd64 platform and bash shell
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system essentials, Python 3.11 (compatible with >=3.10,<3.14), build tools, git, curl, wget, Rust toolchain, and libraries for Python packages
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
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && rm -rf /var/lib/apt/lists/*

# Install Rust compiler for building native Python extensions (e.g., tiktoken)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create Python 3.11 virtual environment at /opt/testbed
RUN python3 -m venv /opt/testbed

# Activate virtual environment, upgrade pip, install uv tool,
# clone repository, checkout given commit SHA, sync all dependencies including dev/extras,
# and install the repo in editable mode with extras [tools,embeddings]
RUN /bin/bash -c "\
    source /opt/testbed/bin/activate && \
    pip install --no-cache-dir --upgrade pip uv && \
    git clone https://github.com/crewAIInc/crewAI /testbed && \
    cd /testbed && \
    git reset --hard 7e6171d5bc35da485e119fef9442faa02fcd0984 && \
    uv sync --dev --all-extras && \
    pip install --no-cache-dir -e '.[tools,embeddings]' \
"

# Set working directory to /testbed
WORKDIR /testbed

# Ensure virtual environment activates by default in interactive root shells
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Set environment variables (can be overridden at runtime)
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED="true"