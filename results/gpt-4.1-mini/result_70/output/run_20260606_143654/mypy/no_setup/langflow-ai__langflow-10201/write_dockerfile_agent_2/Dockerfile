# Base image with stable Ubuntu and bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies and tools including dependencies for Python 3.13 installation
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    curl \
    ca-certificates \
    libssl-dev \
    libffi-dev \
    locales \
    locales-all \
    tzdata \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA for newer Python versions
RUN add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y python3.13 python3.13-venv python3.13-distutils python3.13-dev python3-pip python3.13-setuptools \
    && rm -rf /var/lib/apt/lists/*

# Update alternatives to use Python 3.13 as default python and python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 1 \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3.13 1 \
 && python3 -m pip install --upgrade pip setuptools wheel

# Install Poetry (for pyproject.toml dependency management)
RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH="/root/.local/bin:$PATH"

# Create and activate python venv named testbed
RUN python3 -m venv /opt/testbed
ENV PATH="/opt/testbed/bin:$PATH"

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA
RUN git clone https://github.com/langflow-ai/langflow.git /testbed \
 && cd /testbed \
 && git reset --hard 676299dc0aa02a088b5be43723023ad8fae6464b

# Install Python dependencies using Poetry inside the virtual environment
# Configure Poetry to not create its own virtualenv since we use system venv
RUN /bin/bash -c "source /opt/testbed/bin/activate && \
    poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi"

# Run make init for project-specific initialization (e.g. install submodules, generate files)
RUN /bin/bash -c "source /opt/testbed/bin/activate && make init"

# Export environment variable LFX_DEV for runtime as required
ENV LFX_DEV=1

# Preserve bash as default shell for container runtime
CMD [ "/bin/bash" ]