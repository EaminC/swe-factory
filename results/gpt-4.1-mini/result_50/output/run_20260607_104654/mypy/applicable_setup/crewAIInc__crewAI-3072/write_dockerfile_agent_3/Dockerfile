FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install basic utilities, build tools, Python 3.11 and related dev packages, Rust toolchain, and certificates
RUN apt-get update && apt-get install -y \
    apt-utils \
    git \
    curl \
    wget \
    build-essential \
    cmake \
    rustc \
    cargo \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3.11-distutils \
    python3-pip \
    python3-setuptools \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Configure locale and update CA certificates
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8 \
    && update-ca-certificates

# Ensure python3 points to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

WORKDIR /testbed

# Upgrade pip, setuptools, and wheel globally
RUN python3 -m pip install --upgrade pip setuptools wheel

# Clone repo and checkout the requested commit
ARG COMMIT_SHA=b09796cd3ff4d5ec3c1870ca6c516b7981d6778a
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed \
    && git reset --hard ${COMMIT_SHA} \
    && git remote remove origin

# Create python virtual environment outside /testbed to avoid packaging issues
RUN python3 -m venv /venv

ENV PATH="/venv/bin:$PATH"

# Upgrade pip, setuptools, and wheel inside virtualenv
RUN pip install --upgrade pip setuptools wheel

# Install uv for python dependency management
RUN pip install uv

# Create and activate uv-managed virtual environment in the project, then install dependencies and package
RUN uv venv
RUN source .venv/bin/activate && \
    pip install 'crewai[tools]' && \
    pip install 'crewai[embeddings]' && \
    pip install -e .

# Build project via uv build
RUN uv build

# Install pre-commit hooks if available, ignoring failure
RUN source .venv/bin/activate && pre-commit install || echo "Skipping pre-commit install"

# Set expected environment variables with empty defaults
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED="true"

# Add environment activation to bashrc for convenience
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

CMD ["/bin/bash"]