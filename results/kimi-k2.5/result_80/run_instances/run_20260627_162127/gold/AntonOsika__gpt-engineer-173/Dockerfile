FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies and Python 3.11
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    curl \
    wget \
    software-properties-common \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set python3 to point to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Set working directory
WORKDIR /testbed/

# Clone repository and checkout specific commit
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed/ && \
    git reset --hard 35c35b3ffab89cfa0eb714f5d5c28c6eb2aa7faa && \
    git remote remove origin && \
    chmod -R 777 /testbed/

# Create virtual environment named 'testbed'
RUN python3.11 -m venv /opt/venv/testbed

# Install dependencies and project in editable mode
RUN /bin/bash -c "source /opt/venv/testbed/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install pytest pytest-cov && \
    pip install -r requirements.txt && \
    pip install -e ."

# Set environment variables
ENV PATH="/opt/venv/testbed/bin:$PATH"
ENV OPENAI_API_KEY="dummy_key_for_testing"

# Configure bash to activate environment on login
RUN echo "source /opt/venv/testbed/bin/activate" >> /root/.bashrc

# Set shell to bash explicitly for subsequent commands
SHELL ["/bin/bash", "-c"]