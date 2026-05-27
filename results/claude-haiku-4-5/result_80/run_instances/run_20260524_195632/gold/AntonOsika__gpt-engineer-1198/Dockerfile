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
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    python3-pip \
    curl \
    locales \
    locales-all \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create symlinks for python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip and install Poetry
RUN python3.10 -m pip install --upgrade pip setuptools wheel && \
    pip install poetry==1.5.1

# Create virtual environment using venv
RUN python3.10 -m venv /opt/testbed

# Set environment variables for the virtual environment
ENV PATH="/opt/testbed/bin:$PATH" \
    VIRTUAL_ENV="/opt/testbed"

# Set default workdir to testbed
WORKDIR /testbed/

# Target Project setup: Clone repository, checkout to specific commit, and install dependencies
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard c1f4a9da5dd0abed15b91f6d1c60464cad84ce6c && \
    git remote remove origin

# Install project dependencies using Poetry
RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi

# Configure shell to activate virtual environment
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Set bash as default shell
CMD ["/bin/bash"]