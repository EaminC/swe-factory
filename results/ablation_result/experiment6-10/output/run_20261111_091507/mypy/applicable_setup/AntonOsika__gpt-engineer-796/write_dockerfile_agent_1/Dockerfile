FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3.10-venv \
    python3-pip \
    python3.10-distutils \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip and install required python packages globally for setup
RUN python3 -m pip install --upgrade pip

WORKDIR /testbed/

# Clone the repository and checkout the specified commit
ARG REPO=https://github.com/AntonOsika/gpt-engineer.git
ARG COMMIT_SHA=9dbddfcbdd69cc064992266aa2a295c110948e33

RUN git clone ${REPO} . && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin

# Create and activate virtual environment, install dependencies (including dev mode install)
RUN python3 -m venv venv && \
    source venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install pytest==7.3.1 black==23.3.0 openai==0.27.8 pre-commit==3.3.3 mypy==1.3.0 && \
    pip install -e .

# Make sure tests and scripts are executable and permissions are set properly
RUN chmod -R a+rwx /testbed

# Set environment variables for shell sessions
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

ENV PATH="/testbed/venv/bin:$PATH"
ENV VIRTUAL_ENV=/testbed/venv

WORKDIR /testbed/