# Use Ubuntu 22.04 as the base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and tools essential for Python development, git operations, and environment setup
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python points to python3.10 and pip is up-to-date
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && python -m pip install --upgrade pip

# Set working directory for the project
WORKDIR /testbed/

# Clone the target repository and checkout the given commit SHA inside the container
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed/ \
    && cd /testbed/ \
    && git reset --hard 7dac88a3f8e8c0610e9e3189c867b19d055dab2d

# Create Python virtual environment and activate it for installation
RUN python -m venv /testbed/venv

# Install the project in editable/development mode along with required dependencies
# Use bash shell to activate venv and run install commands
RUN /bin/bash -c "source /testbed/venv/bin/activate \
    && pip install --upgrade pip \
    && pip install --upgrade setuptools wheel \
    && pip install black==23.3.0 click>=8.0.0 mypy==1.3.0 openai==0.27.8 pre-commit==3.3.3 pytest==7.3.1 ruff==0.0.272 termcolor==2.3.0 typer>=0.3.2 rudder-sdk-python==2.0.2 dataclasses-json==0.5.7 tiktoken>=0.0.4 tabulate==0.9.0 python-dotenv>=0.21.0 langchain>=0.0.240 agent-protocol==1.0.1 \
    && pip install -e ."

# Set environment variable to ensure bash shell on container start
ENV SHELL=/bin/bash

# Append virtual environment activation to bashrc for convenience
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc