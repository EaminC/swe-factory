# Use Ubuntu 22.04 LTS as the base image to ensure bash availability and stability
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and essential tools including git, curl, python3.10, pip, and build essentials
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    python3-setuptools \
    unzip \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.10 and pip to pip3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
RUN python3 -m pip install --upgrade pip

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    git checkout c59173a762c7fa7fb1ccad8bee2596131db8f07b

# Create and activate a virtual environment called 'testbed' and install dependencies per README and pyproject.toml:
# 1) Install wheel first (commonly needed)
# 2) pip install the locally built distribution (as per "pip install dist/*.tar.gz" note)
# 3) Install crewAI and extra dependencies as indicated:
#    - crewai
#    - crewai[tools]
#    - crewai[embeddings]
#    - tiktoken (with --prefer-binary)
# 4) Install development dependencies (pytest and others) from pyproject.toml via pip
RUN python3 -m venv /testbed/testbed

# Install dependencies inside the virtual environment
RUN /bin/bash -c " \
    source /testbed/testbed/bin/activate && \
    pip install --upgrade pip wheel setuptools && \
    pip install crewai && \
    pip install 'crewai[tools]' && \
    pip install 'crewai[embeddings]' && \
    pip install tiktoken --prefer-binary && \
    pip install ruff>=0.13.1 mypy>=1.18.2 pre-commit>=4.3.0 bandit>=1.8.6 pytest>=8.4.2 pytest-asyncio>=1.2.0 pytest-subprocess>=1.5.3 vcrpy==7.0.0 pytest-recording>=0.13.4 pytest-randomly>=4.0.1 pytest-timeout>=2.4.0 pytest-xdist>=3.8.0 pytest-split>=0.10.0 typing-extensions boto3-stubs && \
    pip install -e . \
"

# Add activation of virtual environment to bashrc for convenience if user execs shell
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# ENV variables from README that are needed for tests but with placeholder values.
ENV OPENAI_API_KEY=sk- \
    SERPER_API_KEY=YOUR_KEY_HERE \
    OTEL_SDK_DISABLED=true

# Set the working directory explicitly (again) to /testbed
WORKDIR /testbed/