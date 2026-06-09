FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and essentials required for adding PPA and other tasks
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg \
    dirmngr \
    software-properties-common \
    locales \
    tzdata \
    curl \
    wget \
    git \
    build-essential \
    unzip \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA for Python 3.10 (to satisfy paddlepaddle 2.4.2 Python compatibility)
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends python3.10 python3.10-venv python3.10-distutils python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Set python3.10 as default python3 and ensure pip for python3.10 is used
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    python3 -m pip install --upgrade pip setuptools wheel virtualenv

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create and activate a virtual environment named testbed with python3.10
RUN python3.10 -m venv /opt/testbed
ENV PATH="/opt/testbed/bin:$PATH"

# Upgrade pip inside the virtual environment
RUN pip install --upgrade pip

# Clone repository and checkout the specific commit
RUN git clone https://github.com/geekan/MetaGPT.git /testbed
WORKDIR /testbed
RUN git reset --hard 8b209d4e17ad7dfc1ad7a80505eac42f71228734

# Install the repository in editable mode with [test] extras
RUN pip install --upgrade pip
RUN pip install -e .[test]

# Install playwright and its dependencies
RUN pip install "playwright>=1.26"
RUN playwright install --with-deps

# Install mermaid-cli globally using npm
RUN npm install -g @mermaid-js/mermaid-cli

# Set environment variable recommended for test execution
ENV ALLOW_OPENAI_API_CALL=0

# Prepare shell environment to activate the virtual environment automatically on shell start
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

WORKDIR /testbed