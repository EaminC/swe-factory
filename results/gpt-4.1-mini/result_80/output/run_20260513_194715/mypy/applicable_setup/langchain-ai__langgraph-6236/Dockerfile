FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies including git, curl, wget, build tools, python3.11 and related packages,
# as well as PostgreSQL client libraries, gcc for compiling native extensions, and docker-compose dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    gcc \
    ca-certificates \
    libpq-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3.11-dev \
    python3-pip \
    apt-transport-https \
    software-properties-common \
    unzip \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, wheel
RUN python3.11 -m pip install --upgrade pip setuptools wheel

# Install docker-ce-cli and docker-compose standalone binary
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && apt-get install -y docker-ce-cli && \
    curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Install poetry via official recommended install method compatible with python3.11
RUN curl -sSL https://install.python-poetry.org | python3.11 -
ENV PATH="/root/.local/bin:$PATH"

# Clone the repository into /testbed and checkout the specific commit SHA
RUN git clone https://github.com/langchain-ai/langgraph.git /testbed && \
    cd /testbed && \
    git reset --hard b0958115c1887d93bfd25229b307406920038cc4

# Set working directory to the subdirectory containing pyproject.toml for poetry
WORKDIR /testbed/libs/checkpoint-postgres

# Install dependencies using poetry without optional groups flags
RUN poetry install --no-root

# Fix permissions to allow ease of use and editing
RUN chmod -R a+rwx /testbed

# Ensure bashrc sources poetry env automatically for interactive use later (optional)
RUN echo "export PATH=\"$PATH\"" >> /root/.bashrc

# Default shell is bash
CMD ["/bin/bash"]