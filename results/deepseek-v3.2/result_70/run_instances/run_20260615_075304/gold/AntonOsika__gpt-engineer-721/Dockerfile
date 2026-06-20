FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including tkinter for Python
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    python3-tk \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set up Python 3.10 (as used in CI)
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y python3.10 python3.10-venv python3.10-dev python3.10-tk && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Create and activate virtual environment
ENV VIRTUAL_ENV=/testbed/venv
RUN python3.10 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Upgrade pip and setuptools
RUN pip install --upgrade pip setuptools wheel

# Clone repository and checkout specific commit
WORKDIR /tmp
RUN git clone https://github.com/AntonOsika/gpt-engineer.git repo && \
    cd repo && \
    git reset --hard 7dac88a3f8e8c0610e9e3189c867b19d055dab2d

# Inspect pyproject.toml to understand dependencies before installation
WORKDIR /tmp/repo
RUN cat pyproject.toml | grep -A5 -B5 "langchain" || true

# Install langchain with a compatible version first
# Based on commit date and langchain version 0.0.240, we need a version that has MODEL_COST_PER_1K_TOKENS
# This specific commit likely works best with langchain 0.0.240-0.0.260 range
RUN pip install "langchain>=0.0.240,<0.0.261"

# Now install the project in development mode
# This will install other dependencies but won't upgrade langchain due to compatible version constraint
RUN pip install -e .

# Install test dependencies
RUN pip install pytest==7.3.1 pytest-cov

# Move repository to /testbed and set as working directory
WORKDIR /testbed
RUN mv /tmp/repo/* /testbed/ && mv /tmp/repo/.git* /testbed/ 2>/dev/null || true

# Set up environment for tests (no API key needed for basic tests)
ENV PYTHONPATH=/testbed:$PYTHONPATH

# Ensure proper permissions
RUN chmod -R 755 /testbed

# Set up bashrc to automatically activate virtual environment
RUN echo "source $VIRTUAL_ENV/bin/activate" >> /root/.bashrc