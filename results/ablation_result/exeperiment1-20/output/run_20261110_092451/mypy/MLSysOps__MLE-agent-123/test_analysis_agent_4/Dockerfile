# Use Ubuntu 22.04 (jammy) to ensure python3.11 packages are available in official repos and deadsnakes PPA
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system packages with no-install-recommends to keep image slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    ca-certificates \
    git \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Create Python 3.11 virtual environment named testbed
RUN python3.11 -m venv /opt/testbed

# Upgrade pip, setuptools and wheel in the virtual environment
RUN /opt/testbed/bin/pip install --upgrade pip setuptools wheel

# Set environment variables for virtual environment usage
ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Clone the target repository and checkout the specific commit SHA
RUN git clone https://github.com/MLSysOps/MLE-agent.git /testbed \
    && cd /testbed \
    && git reset --hard cc7d248e9ec8f9359d7454017ddc6a31bde840b4

# Install dependencies from requirements.txt and install the repository itself in editable mode
RUN pip install -r /testbed/requirements.txt \
    && pip install -e /testbed

# Set working directory
WORKDIR /testbed

# Optional: activate virtual environment automatically on container start by sourcing in bashrc
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc