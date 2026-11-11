# Use a robust Ubuntu base with Bash and wide compatibility
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies, git, python3.11, build tools, curl, and locales without Rust packages initially
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       git \
       wget \
       curl \
       build-essential \
       python3.11 \
       python3.11-venv \
       python3.11-distutils \
       python3-pip \
       ca-certificates \
       locales \
       tzdata \
       gcc \
       g++ \
       unzip \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Install Rust toolchain using rustup (separate step to avoid overlayfs issues)
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"

# Set workdir
WORKDIR /testbed/

# Clone repo and check out the specified commit (4e496d7a202802917ad4f47eb9efdd6a41f06e18)
RUN git clone --depth 1 https://github.com/crewAIInc/crewAI /testbed && \
    git fetch --depth=1 origin 4e496d7a202802917ad4f47eb9efdd6a41f06e18 && \
    git reset --hard 4e496d7a202802917ad4f47eb9efdd6a41f06e18 && \
    git remote remove origin

# Create Python virtual environment named "testbed"
RUN python3 -m venv /testbed/venv

# Install core dependencies and develop mode repo with required extras [tools] inside the virtual environment
RUN /bin/bash -c "source /testbed/venv/bin/activate && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir 'crewai[tools]' && \
    pip install --no-cache-dir -e ."

# Skip modifying /root/.bashrc to avoid containerd mount errors; activate the virtual environment at runtime instead.

ENV PATH="/testbed/venv/bin:$PATH"
ENV PYTHONPATH="/testbed/:$PYTHONPATH"