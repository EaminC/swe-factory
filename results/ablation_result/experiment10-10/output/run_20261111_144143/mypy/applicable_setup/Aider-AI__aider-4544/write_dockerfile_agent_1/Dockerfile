# Use Ubuntu 22.04 as base to ensure bash and wide compatibility
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies: git, wget, curl, python3, python3-pip, build essentials, locales (to avoid locale warnings)
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3-setuptools \
    locales \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install pip latest version
RUN python3.11 -m pip install --upgrade pip

# Set up virtual environment for isolation, named testbed
RUN python3.11 -m venv /opt/testbed
ENV PATH="/opt/testbed/bin:$PATH"

# Upgrade pip and install pip-tools to manage pinned dev dependencies files
RUN /opt/testbed/bin/pip install --upgrade pip pip-tools

# Set workdir
WORKDIR /testbed/

# Clone target repository, checkout specific commit and remove origin
ARG REPO_URL=https://github.com/Aider-AI/aider.git
ARG COMMIT_SHA=249e38976508007aeda1c74344c83e1e37ec8e14
RUN git clone $REPO_URL . && \
    git reset --hard $COMMIT_SHA && \
    git remote remove origin

# Install repository's installation tool and dev dependencies in editable mode inside venv:
# 1) install aider-install tool (as per instructions)
# 2) run aider-install shell (simulate this by running aider-install command with no interactive)
# 3) install dev requirements (using pip install -r requirements/requirements-dev.txt)
# Then install repository code in editable mode: pip install -e .

# Step 1: install 'aider-install' package (likely a PyPI package)
RUN /bin/bash -c "source /opt/testbed/bin/activate && \
    pip install aider-install"

# Step 2: run aider-install (non-interactive; we assume it sets up environment config files or installs deps)
RUN /bin/bash -c "source /opt/testbed/bin/activate && aider-install"

# Step 3: install dev requirements from requirements/requirements-dev.txt
RUN /bin/bash -c "source /opt/testbed/bin/activate && pip install -r requirements/requirements-dev.txt"

# Step 4: install the local repository in editable/development mode to ensure local code is used
RUN /bin/bash -c "source /opt/testbed/bin/activate && pip install -e ."

# Add environment variable for tests, based on pytest config
ENV AIDER_ANALYTICS=false

# Default shell
SHELL ["/bin/bash", "-c"]

# Ensure that the virtual environment is activated by default for any RUN or ENTRYPOINT commands
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc
ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"