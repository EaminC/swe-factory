# Base image specification. Defines the foundation OS and architecture for the container
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation. Installs essential tools and libraries required for development and runtime
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    curl \
    locales \
    locales-all \
    tzdata \
    python3 \
    python3-pip \
    python3-venv \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.10 explicitly (required version range: >=3.10, <3.13)
RUN apt update && apt install -y software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt update && apt install -y python3.10 python3.10-venv python3.10-dev \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && rm -rf /var/lib/apt/lists/*

# Install UV using pip first (as it's listed as a dependency in pyproject.toml)
RUN pip3 install uv>=0.4.25

# Set default workdir to testbed
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/crewAIInc/crewAI /testbed \
    && chmod -R 777 /testbed \
    && cd /testbed \
    && git reset --hard 9dffd42e6d3b81973e6b4e76fdb906dae649e04a \
    && git remote remove origin

# Set up Python environment and install dependencies using UV (as per CI workflow)
# First install the specific Python version using uv
RUN uv python install 3.10

# Install project dependencies with all extras and dev dependencies (as per CI workflow)
RUN uv sync --dev --all-extras

# Install the project in development mode
RUN uv pip install -e .

# Set environment variables (required for tests)
ENV OPENAI_API_KEY="test-key"
ENV SERPER_API_KEY="test-key"
ENV OTEL_SDK_DISABLED="true"

# Add uv to PATH for convenience (uv is already in PATH from pip installation)
RUN echo "export PATH=\$PATH:/usr/local/bin" >> /root/.bashrc