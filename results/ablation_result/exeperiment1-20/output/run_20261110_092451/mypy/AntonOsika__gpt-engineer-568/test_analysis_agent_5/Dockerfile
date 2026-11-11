# Use Ubuntu 22.04 as stable base with bash shell
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essentials in smaller steps to reduce peak memory usage
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Configure locale and timezone environment variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed
RUN cd /testbed && git reset --hard f84754d54ee311146c4f52b5e3ceb0fa8d0b731b

# Create and activate a Python virtual environment explicitly using python3.10
RUN python3.10 -m venv /testbed/venv

# Upgrade pip and install editable package plus pytest inside the venv
RUN /bin/bash -c "source /testbed/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -e . && \
    pip install pytest"

# Environment variables for activating the virtualenv by default
ENV VIRTUAL_ENV=/testbed/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Set bash as default shell
SHELL ["/bin/bash", "-c"]