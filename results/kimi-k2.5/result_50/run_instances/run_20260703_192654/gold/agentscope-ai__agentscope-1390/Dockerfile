FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including build tools and libraries required for audio processing
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    python3.10 \
    python3.10-dev \
    python3-pip \
    python-is-python3 \
    libportaudio2 \
    locales \
    tzdata \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Set workdir
WORKDIR /testbed/

# Clone repository and checkout specific commit
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed/ && \
    git reset --hard 8faa353e579591f99f3322a1aab3f35f2abafdf8 && \
    git remote remove origin

# Upgrade pip and install specific build tools as per CI requirements
RUN python3 -m pip install --upgrade pip && \
    pip install setuptools==78.1.1 wheel==0.45.1

# Install package in development mode with dev dependencies
RUN pip install -e .[dev]

# Install additional test-specific dependencies explicitly (ensuring test requirements are met)
RUN pip install pytest pytest-asyncio pytest-forked fakeredis aiosqlite coverage

# Set environment variables for test execution as per unittest.yml
ENV GRPC_VERBOSITY=ERROR
ENV OS=Linux

# Ensure permissions are open for test execution
RUN chmod -R 777 /testbed/