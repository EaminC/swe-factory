FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies including git, build tools, and libraries needed for compilation
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3-dev \
    libjpeg-dev \
    zlib1g-dev \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda for Python environment management
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py311_23.11.0-2-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/miniconda3 \
    && rm /tmp/miniconda.sh

ENV PATH=/opt/miniconda3/bin:$PATH

# Initialize conda and create the testbed environment with Python 3.11 (within 3.10-3.12 range)
RUN conda init bash \
    && conda create -n testbed python=3.11 -y \
    && conda clean -afy

# Install Poetry package manager in the testbed environment
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    pip install poetry==1.7.1"

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
# Commit SHA: c1f4a9da5dd0abed15b91f6d1c60464cad84ce6c
RUN git clone https://github.com/AntonOsika/gpt-engineer.git /testbed/ \
    && git reset --hard c1f4a9da5dd0abed15b91f6d1c60464cad84ce6c \
    && git remote remove origin \
    && chmod -R 777 /testbed/

# Install project dependencies using Poetry (installs in development/editable mode)
# Configure Poetry to not create a virtualenv since we are using Conda
RUN /bin/bash -c "source /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate testbed && \
    poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi"

# Configure bashrc to automatically activate the testbed environment
RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc

# Set default shell to bash
SHELL ["/bin/bash", "-c"]