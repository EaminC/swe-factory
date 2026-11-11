FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN python3.10 -m pip install --upgrade pip setuptools wheel

RUN git clone https://github.com/AntonOsika/gpt-engineer /testbed

WORKDIR /testbed

RUN git reset --hard 2b8e056d5d4d14665b88a01c41356253c94b9259

RUN python3.10 -m venv /testbed/testbed

# Activate virtual environment, upgrade pip and setuptools, install project in development mode,
# and explicitly install missing 'tiktoken' dependency required by tests
RUN /bin/bash -c "\
    source /testbed/testbed/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -e . && \
    pip install tiktoken"

ENV OPENAI_API_KEY=""

SHELL ["/bin/bash", "-c"]