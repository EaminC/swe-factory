FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install apt-utils first to improve package management stability
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils && rm -rf /var/lib/apt/lists/*

# Install system dependencies and tools in smaller logical chunks with cache cleaning after each chunk
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl git \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libffi-dev python3-pip python3-venv python3-distutils \
    locales locales-all tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry (dependency manager)
RUN curl -sSL https://install.python-poetry.org | python3 -

# Put poetry bin in PATH for following steps explicitly in bash profile and ENV
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> /root/.bashrc
ENV PATH="/root/.local/bin:$PATH"

# Create working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA
ARG REPO_URL=https://github.com/AntonOsika/gpt-engineer.git
ARG COMMIT_SHA=a74c5ebcf0abf9db63abf3ba39ac123f6f74eb82

RUN git clone ${REPO_URL} /testbed && \
    cd /testbed && \
    git reset --hard ${COMMIT_SHA} && \
    chmod -R a+rwx /testbed

# Setup Python virtual environment
RUN python3 -m venv /testbed/testbed-venv

# Install dependencies using Poetry inside the virtual environment and install the local package in editable mode
RUN /bin/bash -c "source /testbed/testbed-venv/bin/activate && \
    poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi && \
    pip install -e ."

# Enable auto-activation of the virtual environment in bash interactive shells
RUN echo "source /testbed/testbed-venv/bin/activate" >> /root/.bashrc

# Set default shell to bash explicitly
ENV SHELL=/bin/bash