# Use official Ubuntu 22.04 base image for a stable environment and manual Python 3.12 installation
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential tools and dependencies in smaller steps to reduce memory usage
RUN apt-get update && apt-get install -y software-properties-common && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y git curl ca-certificates wget lsb-release && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y build-essential && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA and update package list
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update

# Install Python 3.12 and related packages
RUN apt-get install -y python3.12 python3.12-venv python3-distutils python3-pip && rm -rf /var/lib/apt/lists/*

# Point python3 to python3.12
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Upgrade pip and setuptools for Python 3.12
RUN python3 -m pip install --upgrade pip setuptools wheel

# Set working directory to /testbed
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/Aider-AI/aider.git /testbed && \
    git checkout ca4141564f86dd1b7dee3082959042dc05d5d471 && \
    git remote remove origin

# Create python virtual environment
RUN python3 -m venv /testbed/testbed-venv

# Install project dependencies inside the virtual environment
RUN /bin/bash -c "source /testbed/testbed-venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt && \
    pip install -e ."

# Enable virtual environment activation in interactive shells
RUN echo "source /testbed/testbed-venv/bin/activate" >> /root/.bashrc