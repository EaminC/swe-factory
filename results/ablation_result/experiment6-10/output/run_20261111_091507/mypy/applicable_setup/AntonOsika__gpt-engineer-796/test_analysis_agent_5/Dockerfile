FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3.10-venv \
    python3-pip \
    python3.10-distutils \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip and install build essentials
RUN python3 -m pip install --upgrade pip setuptools wheel

WORKDIR /testbed/

# Clone the repository and checkout the specified commit
ARG REPO=https://github.com/AntonOsika/gpt-engineer.git
ARG COMMIT_SHA=9dbddfcbdd69cc064992266aa2a295c110948e33

RUN git clone ${REPO} . && \
    git reset --hard ${COMMIT_SHA} && \
    git remote remove origin

# Create and activate virtual environment, install pinned dependencies excluding those managed by the local repo,
# pin langchain explicitly to version 0.0.241 which includes the required MODEL_COST_PER_1K_TOKENS symbol,
# then install the repository itself in editable mode
RUN python3 -m venv venv && \
    source venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    pip install \
      pytest==7.3.1 \
      openai==0.27.8 \
      rudder-sdk-python==2.0.2 \
      dataclasses-json==0.5.7 \
      tiktoken>=0.0.4 \
      tabulate==0.9.0 \
      python-dotenv>=0.21.0 \
      agent-protocol==1.0.1 \
      "langchain==0.0.241" && \
    pip install -e .

# Set permissions
RUN chmod -R a+rwx /testbed

# Configure shell environment
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

ENV PATH="/testbed/venv/bin:$PATH"
ENV VIRTUAL_ENV=/testbed/venv

WORKDIR /testbed/