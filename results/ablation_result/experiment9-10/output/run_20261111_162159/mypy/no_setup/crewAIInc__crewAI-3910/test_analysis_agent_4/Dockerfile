# Use Ubuntu 22.04 LTS as base image to ensure bash availability and stability
FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Update apt and install essential system dependencies and tools in smaller steps to reduce layer complexity
RUN apt-get update && apt-get install -y git curl wget build-essential unzip locales && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y python3.10 python3.10-venv python3.10-distutils python3-pip python3-setuptools && \
    rm -rf /var/lib/apt/lists/*

# Update-alternatives to point python3 to python3.10 in a separate RUN command to isolate possible issues
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 || true

# Upgrade pip, wheel, setuptools in isolated step
RUN python3 -m pip install --upgrade pip wheel setuptools

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    cd /testbed && \
    git checkout c59173a762c7fa7fb1ccad8bee2596131db8f07b

# Create the virtual environment
RUN python3 -m venv /testbed/testbed

# Install minimal required tool uv explicitly to avoid missing 'uv' binary in venv
RUN /bin/bash -c "source /testbed/testbed/bin/activate && pip install uv"

# Install dev dependencies declared in pyproject.toml with "dev" extra using explicit installs except main package
RUN /bin/bash -c "source /testbed/testbed/bin/activate && \
    pip install ruff>=0.13.1 mypy>=1.18.2 pre-commit>=4.3.0 bandit>=1.8.6 pytest>=8.4.2 pytest-asyncio>=1.2.0 pytest-subprocess>=1.5.3 vcrpy==7.0.0 pytest-recording>=0.13.4 pytest-randomly>=4.0.1 pytest-timeout>=2.4.0 pytest-xdist>=3.8.0 pytest-split>=0.10.0 typing-extensions boto3-stubs tiktoken --prefer-binary 'crewai[tools]' 'crewai[embeddings]'"

# Build the package wheel and install it without editable mode to avoid flat-layout issue
RUN /bin/bash -c "source /testbed/testbed/bin/activate && \
    cd /testbed && \
    pip install build && \
    python -m build --wheel --no-isolation -o dist/ && \
    pip install dist/*.whl"

# Add activation of virtual environment to bashrc for convenience if user execs shell
RUN echo "source /testbed/testbed/bin/activate" >> /root/.bashrc

# Environment variables needed for tests with placeholders
ENV OPENAI_API_KEY=sk- \
    SERPER_API_KEY=YOUR_KEY_HERE \
    OTEL_SDK_DISABLED=true

WORKDIR /testbed/