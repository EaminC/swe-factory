# Base image specification: Ubuntu 22.04 with Bash as default shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies: wget, git, curl, build essentials, python3, python3-pip, bash, locales
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

# Install "uv" tool (UV tool) -- using pip, as no explicit system installation method known.
# Assuming "uv" is a Python package based on naming, install it globally via pip
RUN pip3 install uv-cli

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout specific commit SHA
RUN git clone https://github.com/crewAIInc/crewAI /testbed/ && \
    git reset --hard 4bc23affe0e322f4c48be7ea4e5abb0e273569d6 && \
    git remote remove origin

# Setup uv environment and install Python 3.11.9 using uv python install (uv tool manages python installations)
RUN /bin/bash -c "\
    uv python install 3.11.9 && \
    uv venv create testbed 3.11.9 && \
    source $(uv venv path testbed)/bin/activate && \
    uv sync --dev --all-extras && \
    pip install -e . \
"

# Add uv environment activation line to root .bashrc for convenient environment activation in container shells
RUN echo "source $(uv venv path testbed)/bin/activate" >> /root/.bashrc

# Set default shell to bash explicitly
SHELL ["/bin/bash", "-c"]

# Expose environment variables placeholders (to be set at runtime)
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""

# WORKDIR is already set to /testbed