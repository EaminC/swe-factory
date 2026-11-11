# Use official Python 3.10 slim base image for a stable and reliable environment
FROM --platform=linux/x86_64 python:3.10-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PLAYWRIGHT_BROWSERS_PATH=/pw-browsers

# Install system dependencies and locales
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    ca-certificates \
    locales \
    libportaudio2 \
    pandoc \
    && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Create Python virtual environment
RUN python3 -m venv /venv

# Set working directory in container
WORKDIR /testbed

# Clone the repository and checkout the specified commit
ARG COMMIT_SHA=0fe5247d4c8aa9ceff28f65c6e7fc04b4ce53ec4
RUN git clone https://github.com/Aider-AI/aider.git /testbed && \
    cd /testbed && \
    git checkout ${COMMIT_SHA}

# Install dependencies inside the virtual environment
RUN /bin/bash -c "source /venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install -e .[help,browser,playwright] && \
    pip install -r requirements.txt && \
    pip install -r requirements/requirements-dev.txt && \
    pip install --index-url https://download.pytorch.org/whl/cpu torch"

# Install Playwright browsers (chromium) as required
RUN /bin/bash -c "source /venv/bin/activate && playwright install chromium"

# Configure git safe directory and set permissions
RUN git config --global --add safe.directory /testbed && \
    chmod -R a+rw /testbed

# Add virtual environment activation to bashrc for interactive shell convenience
RUN echo "source /venv/bin/activate" >> /root/.bashrc

# Use bash as default shell
SHELL ["/bin/bash", "-c"]