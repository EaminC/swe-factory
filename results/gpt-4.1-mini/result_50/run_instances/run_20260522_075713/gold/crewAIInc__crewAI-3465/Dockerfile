# Use Ubuntu 22.04 as base image with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies including rust compiler from apt for build requirements
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    rustc \
    ca-certificates \
    locales-all \
    tzdata \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Hatchling build system globally (used by the project)
RUN python3 -m pip install --no-cache-dir --upgrade pip
RUN python3 -m pip install --no-cache-dir hatchling

# Set working directory
WORKDIR /testbed

# Clone repo, checkout to specific commit, and remove origin remote for reproducibility
ARG COMMIT_SHA=1dc4f2e8977eb68b54dc3184a9548dfe10e57f3e
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin

# Create Python virtual environment named testbed_venv
RUN python3 -m venv /testbed/testbed_venv

# Activate virtual environment, upgrade pip, install necessary testing dependencies,
# then minimum, exact, and optional dependencies explicitly,
# and lastly install the package in editable mode without pre-installing repo packages
RUN /bin/bash -c "\
    source /testbed/testbed_venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir 'pytest>=8.0.0' 'pytest-asyncio>=0.23.7' 'pytest-subprocess>=1.5.2' 'pytest-recording>=0.13.2' 'pytest-randomly>=3.16.0' 'pytest-timeout>=2.3.1' 'pytest-xdist>=3.6.1' 'pytest-split>=0.9.0' && \
    pip install --no-cache-dir 'litellm==1.74.9' 'onnxruntime==1.22.0' 'json-repair==0.25.2' 'portalocker==2.7.0' && \
    pip install --no-cache-dir 'pydantic>=2.4.2' 'openai>=1.13.3' 'instructor>=1.3.3' 'pdfplumber>=0.11.4' 'regex>=2024.9.11' 'opentelemetry-api>=1.22.0' 'opentelemetry-sdk>=1.22.0' 'chromadb>=0.5.23' 'tokenizers>=0.20.3' 'openpyxl>=3.1.5' 'python-dotenv>=1.0.0' 'pyjwt>=2.9.0' 'click>=8.1.7' && \
    pip install --no-cache-dir 'crewai-tools~=0.69.0' 'tiktoken~=0.8.0' 'mem0ai>=0.1.94' 'docling>=2.12.0' 'aisuite>=0.1.10' 'qdrant-client[fastembed]>=1.14.3' && \
    pip install --no-cache-dir -e '.[tools,embeddings]' \
"

# Add virtual environment activation to root bashrc for convenience during interactive sessions
RUN echo "source /testbed/testbed_venv/bin/activate" >> /root/.bashrc

# Environment variables placeholders for user injection at runtime
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED="true"

# Default shell
SHELL ["/bin/bash", "-c"]