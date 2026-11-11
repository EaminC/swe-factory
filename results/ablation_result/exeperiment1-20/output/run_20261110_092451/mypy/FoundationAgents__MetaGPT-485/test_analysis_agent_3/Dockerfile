FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies and essentials
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    python3-venv \
    python3-distutils \
    python3-pip \
    nodejs \
    npm \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Ensure python command points to python3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Upgrade pip
RUN python -m pip install --upgrade pip

# Create a python virtual environment named 'testbed'
RUN python -m venv /opt/testbed

# Add virtual environment to PATH
ENV PATH="/opt/testbed/bin:$PATH"
WORKDIR /testbed/

# Clone the repository, checkout the specific commit, install python dependencies in the virtualenv
RUN /bin/bash -c "\
    git clone https://github.com/FoundationAgents/MetaGPT /testbed && \
    cd /testbed && \
    git reset --hard 384f5ee08b6defef2adfb22274283e8bd0ef4314 && \
    source /opt/testbed/bin/activate && \
    pip install pytest==7.2.2 pytest-mock==3.11.1 playwright pyppeteer && \
    pip install -e . \
"

# Install Playwright browsers required for playwright package
RUN /bin/bash -c "source /opt/testbed/bin/activate && playwright install"

# Setup environment variables placeholders for runtime usage
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=""
ENV OPENAI_API_KEY=""
ENV OPENAI_API_BASE=""

# Fix ownership and permissions
RUN chmod -R 777 /testbed

# Use bash as default shell explicitly
SHELL ["/bin/bash", "-c"]