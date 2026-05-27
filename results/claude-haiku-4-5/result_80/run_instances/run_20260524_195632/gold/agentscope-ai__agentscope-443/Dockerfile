# Base image specification with Python 3.9
FROM --platform=linux/x86_64 python:3.9-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies installation
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    curl \
    wget \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Set default workdir to testbed
WORKDIR /testbed/

# Target Project setup
# Clone the repository, checkout to the target commit, and install dependencies
RUN git clone https://github.com/agentscope-ai/agentscope /testbed && \
    chmod -R 777 /testbed && \
    cd /testbed && \
    git reset --hard 6c823a955c7be783a2a34c64d13b74aee8c552bf && \
    git remote remove origin

# Install project in development mode with test dependencies and required optional extras
RUN pip install --upgrade pip setuptools wheel && \
    pip install pytest pytest-cov && \
    pip install -e ".[gemini,ollama,zhipuai]"

# Set bash as the default shell
RUN echo "#!/bin/bash" > /etc/profile.d/init.sh && chmod +x /etc/profile.d/init.sh

CMD ["/bin/bash"]