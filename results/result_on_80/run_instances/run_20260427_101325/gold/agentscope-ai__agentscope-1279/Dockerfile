# Use Ubuntu 22.04 as base image with bash shell and stable environment
FROM --platform=linux/amd64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies including git, python3.10, venv, curl, build-essential, locales and tzdata
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    build-essential \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 and pip point to python3.10 and install latest pip via official get-pip.py script
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

# Remove /testbed if it exists to avoid git clone failure
RUN rm -rf /testbed

# Set working directory before cloning
WORKDIR /testbed

# Clone the repository and checkout the specific commit SHA
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed && \
    git reset --hard 28cfb99a21902d330dab6cb3762a739198cf972f

# Create python virtual environment
RUN python3.10 -m venv testbed

# Upgrade pip, setuptools, and wheel, then install the project in editable mode with dev dependencies including coverage, pytest, and pre-commit
RUN /bin/bash -c "source testbed/bin/activate && \
    pip install --upgrade pip setuptools==78.1.1 wheel==0.45.1 && \
    pip install -e '.[dev]' && \
    pip install --no-cache-dir coverage pytest pre-commit"

# Setup pre-commit hooks (installation only, no running)
RUN /bin/bash -c "source testbed/bin/activate && pre-commit install" || true

# Add the virtual environment activation to bashrc for convenience
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Set PATH to ensure virtual environment's bin is used by default (makes coverage accessible in eval script)
ENV PATH="/testbed/testbed/bin:$PATH"

# Environment variables placeholders for user override
ENV DASHSCOPE_API_KEY=""
ENV GAODE_API_KEY=""

# Ensure bash is default shell
ENV SHELL=/bin/bash