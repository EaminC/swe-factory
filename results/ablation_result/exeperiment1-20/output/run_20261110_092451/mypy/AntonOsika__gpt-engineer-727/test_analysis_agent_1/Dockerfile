# Base image specification with stable Ubuntu and bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
SHELL ["/bin/bash", "-c"]

# System dependencies installation: git, Python3.10 and development tools required
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    libffi-dev \
    libssl-dev \
    python3.10 \
    python3.10-distutils \
    python3.10-venv \
    python3-pip \
    python3-setuptools \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip for the default python
RUN python3 -m pip install --upgrade pip

# Create and activate Python virtual environment 'testbed'
RUN python3 -m venv /testbed/venv

# Activate virtual environment and install project dependencies with pinned versions
# Cloning, checkout, and pip install -e done in one layered RUN to keep cleanliness and reproducibility
RUN /bin/bash -c " \
    source /testbed/venv/bin/activate && \
    git clone https://github.com/AntonOsika/gpt-engineer.git /testbed && \
    cd /testbed && \
    git checkout 27e2566cff7e3dcf79f37b5271efbc1c0c01c3e0 && \
    pip install --upgrade pip && \
    pip install -e . && \
    pip install pytest==7.3.1 black==23.3.0 mypy==1.3.0 openai==0.27.8 pre-commit==3.3.3 ruff==0.0.272 termcolor==2.3.0 rudder-sdk-python==2.0.2 dataclasses-json==0.5.7 tabulate==0.9.0 agent-protocol==1.0.1 && \
    pip install 'click>=8.0.0' 'typer>=0.3.2' 'tiktoken>=0.0.4' 'python-dotenv>=0.21.0' 'langchain>=0.0.240' \
"

# Set working directory
WORKDIR /testbed/

# Set environment variables for virtualenv activation when a shell is started
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc
ENV VIRTUAL_ENV=/testbed/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# No ENTRYPOINT or CMD - tests will be run externally as per instructions