# Base image specification: Ubuntu 22.04 with Bash as default shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies: wget, git, curl, build essentials, python3.11, python3-pip, bash, locales
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3-pip \
    python3.11-distutils \
    locales \
    locales-all \
    tzdata \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Setup python3.11 as default python3 and pip3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 -

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA
RUN git clone https://github.com/crewAIInc/crewAI /testbed/ && \
    git reset --hard 4bc23affe0e322f4c48be7ea4e5abb0e273569d6 && \
    git remote remove origin

# Install project dependencies and dev dependencies inside a python virtual environment using standard tools (no uv-cli installation)
# Create virtual environment and activate it, then:
#   - install core dependencies and dev dependencies with pip and editable install of local repo plus extras
RUN python3 -m venv /testbed/.venv
ENV PATH="/testbed/.venv/bin:$PATH"
RUN pip install --upgrade pip setuptools wheel
RUN pip install -e .[dev]

# Add virtual environment activation to bashrc for interactive usage
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Set default shell to bash explicitly
SHELL ["/bin/bash", "-c"]

# Environment variable placeholders to be set at runtime
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""

# WORKDIR is already set to /testbed/