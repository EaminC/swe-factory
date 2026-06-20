# Base image: Ubuntu 22.04 with bash
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    curl \
    locales \
    tzdata \
    ca-certificates \
    python3 \
    python3-pip \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# Install uv and Python 3.12.8 (within the supported range: >=3.10, <3.14)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && export PATH="/root/.local/bin:$PATH" \
    && uv python install 3.12.8

# Set PATH for uv and Python (uv installs to ~/.local/bin)
ENV PATH="/root/.local/bin:$PATH"

# Verify installations
RUN uv --version && python3 --version

# Set default workdir
WORKDIR /testbed/

# Clone repository and checkout target commit
RUN git clone https://github.com/crewAIInc/crewAI /testbed \
    && cd /testbed \
    && git reset --hard c96d4a6823fb5a3ef196427612b784efe504fdce \
    && git remote remove origin

# Install project dependencies (including dev and extras) using uv
RUN cd /testbed && uv sync --dev --all-extras

# Install the package in development mode
RUN cd /testbed && uv pip install -e .

# Set environment variables for testing (as per README)
ENV OPENAI_API_KEY=fake-api-key
ENV SERPER_API_KEY=fake-api-key
ENV OTEL_SDK_DISABLED=true

# Set up bashrc to persist environment
RUN echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc

# Ensure testbed is writable
RUN chmod -R 777 /testbed