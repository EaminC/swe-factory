FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and python3.10 with venv and distutils
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ca-certificates \
    bzip2 \
    build-essential \
    libffi-dev \
    libssl-dev \
    locales \
    locales-all \
    tzdata \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    && rm -rf /var/lib/apt/lists/*

# Setup python alternative to python3.10 and install pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# Install pip for python3.10
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python

# Install virtualenv for isolated environment management
RUN pip install --no-cache-dir virtualenv

# Remove /testbed contents before creating venv to avoid conflicts
RUN rm -rf /testbed/* || true

# Create virtual environment in /testbed/testbed using python3.10 explicitly
RUN python3.10 -m venv /testbed/testbed

# Verify the virtual environment was created correctly and list contents for debug
RUN ls -la /testbed/testbed && test -f /testbed/testbed/bin/activate

# Ensure virtualenv activation on interactive shells
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Set working directory to a subdirectory for cloning
WORKDIR /testbed/agentscope

# Clone the target repository into /testbed/agentscope
RUN git clone https://github.com/modelscope/agentscope.git .

# Checkout specific commit SHA
ARG COMMIT_SHA=6c823a955c7be783a2a34c64d13b74aee8c552bf
RUN git reset --hard ${COMMIT_SHA}

# Install project and dev dependencies inside virtual environment (do not pre-install anything else)
RUN /bin/bash -c "source /testbed/testbed/bin/activate && pip install --upgrade pip && pip install -e .[dev]"

# Install pre-commit hooks inside virtual environment as recommended
RUN /bin/bash -c "source /testbed/testbed/bin/activate && pre-commit install"

# Set default shell to bash
ENV SHELL=/bin/bash