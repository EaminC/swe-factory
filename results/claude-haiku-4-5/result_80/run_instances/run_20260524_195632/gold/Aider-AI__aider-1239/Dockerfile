# Base image specification with Python support
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    libffi-dev \
    libtiff-dev \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    python-is-python3 \
    jq \
    curl \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as the default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Upgrade pip
RUN python3 -m pip install --upgrade pip setuptools wheel

# Set default workdir
WORKDIR /testbed/

# Target Project setup
# Clone the repository and checkout to the specific commit
RUN git clone https://github.com/Aider-AI/aider /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard 301c4265b76a5b8c4a939acb59314e091cacebec && \
    git remote remove origin

# Install core dependencies from requirements.txt
RUN pip install -r requirements.txt

# Install testing dependencies (pytest, pytest-asyncio, pytest-timeout)
RUN pip install pytest pytest-asyncio pytest-timeout

# Install the project in development mode
RUN pip install -e .

# Set bash as the default shell
RUN echo "/bin/bash" > /etc/shells

CMD ["/bin/bash"]