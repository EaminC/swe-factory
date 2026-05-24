# Use Ubuntu 22.04 as the base image, supports bash by default
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system packages including Python 3.10, git, curl, build essentials, and libraries required for Python packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to latest version explicitly using python3.10
RUN python3.10 -m pip install --no-cache-dir --upgrade pip

# Install Rust compiler (required for some dependencies like tiktoken)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create Python virtual environment named 'testbed' with python3.10
RUN python3.10 -m venv /opt/testbed

# Activate the virtual environment and install the repository with optional dependencies [tools, embeddings]
# Clone the repo and checkout the specified commit SHA c96d4a6823fb5a3ef196427612b784efe504fdce
# Install in editable mode with required extras
RUN /bin/bash -c "\
    source /opt/testbed/bin/activate && \
    pip install --no-cache-dir --upgrade pip && \
    git clone https://github.com/crewAIInc/crewAI /testbed && \
    cd /testbed && \
    git reset --hard c96d4a6823fb5a3ef196427612b784efe504fdce && \
    pip install --no-cache-dir -e '.[tools,embeddings]' \
"

WORKDIR /testbed

# Make bash activate the virtual environment by default for interactive sessions
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Set environment variables placeholders for user to inject prior to running tests or usage
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED="true"

# Explicitly set bash as default shell
SHELL ["/bin/bash", "-c"]