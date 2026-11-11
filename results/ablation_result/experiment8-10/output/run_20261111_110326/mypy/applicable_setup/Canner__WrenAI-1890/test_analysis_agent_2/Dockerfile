# Use ubuntu 22.04 as base to have bash and stable environment
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Add deadsnakes PPA to provide python3.12 packages on Ubuntu 22.04
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && apt-get update

# Install system dependencies: git, curl, build essentials, python3.12 and tools
RUN apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    locales \
    tzdata \
    gcc \
    g++ \
    pkg-config \
    libffi-dev \
    libssl-dev \
    python3.12 \
    python3.12-distutils \
    python3.12-venv \
    && rm -rf /var/lib/apt/lists/*

# Set python3 to python3.12
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Install pip for python3.12
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3 -

# Install Poetry (pin to 1.8.3 as per context)
RUN curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.8.3 python3 -

ENV PATH="/root/.local/bin:$PATH"

WORKDIR /testbed/

# Clone the repository and checkout the specified commit
ARG COMMIT_SHA
RUN git clone https://github.com/Canner/WrenAI.git /testbed && \
    git reset --hard $COMMIT_SHA

# Configure Poetry to create virtualenvs inside the project folder
RUN poetry config virtualenvs.in-project true

# Install project dependencies without eval group
RUN poetry install --without eval

# Install the project itself in editable mode from the cloned repo
RUN /bin/bash -c "source /testbed/.venv/bin/activate && cd /testbed && poetry run pip install -e ."

# Enable auto activation of poetry virtualenv on bash login
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

WORKDIR /testbed/