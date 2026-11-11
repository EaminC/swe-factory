# Base image Ubuntu 22.04, which natively supports Python 3.11 packages
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and tools including git, python3.11, pip, build essentials
RUN apt update && apt install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    locales \
    tzdata \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Set python3 and python to point to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Upgrade pip and setuptools to latest versions for python3.11
RUN python3 -m pip install --upgrade pip setuptools

# Create virtual environment named "testbed"
RUN python3 -m venv /opt/testbed

ENV PATH="/opt/testbed/bin:$PATH"

# Upgrade pip and setuptools inside the virtual environment
RUN pip install --upgrade pip setuptools

# Set working directory where repo will be cloned
WORKDIR /testbed

# Clone the repository and checkout specific commit, then install dependencies and repo itself in editable mode
RUN git clone https://github.com/MLSysOps/MLE-agent.git . \
 && git reset --hard b95f56b446a2fe55247eee717ab85fe45f857d27 \
 && pip install -r requirements.txt \
 && pip install -e .

# Add activation of virtual environment to root bashrc for interactive sessions
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Default shell bash to ensure compatibility
SHELL ["/bin/bash", "-c"]