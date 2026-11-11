FROM continuumio/miniconda3:latest
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Fix Debian bullseye old repos 404 by switching to archive.debian.org sources if detected
RUN if grep -q bullseye /etc/os-release; then \
      sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
      sed -i '/security.debian.org/d' /etc/apt/sources.list && \
      echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99disable-check-valid-until ; \
    fi

# Install system dependencies and essential tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Initialize conda, configure channels, and create Python 3.10 environment named testbed
RUN conda config --append channels conda-forge && \
    conda create -n testbed python=3.10 -y

# Set the default shell to activate conda environment
SHELL ["conda", "run", "-n", "testbed", "/bin/bash", "-c"]

# Set WORKDIR and clone repo, checkout specific commit
WORKDIR /testbed/
RUN git clone https://github.com/Aider-AI/aider.git /testbed && \
    git reset --hard 17d40a62c931ac91fc9c31288310b37b62175c47

# Install Python dependencies from requirements.txt and install in editable mode, inside testbed env
RUN pip install -r requirements.txt && pip install -e .

# Revert to default bash shell
SHELL ["/bin/bash", "-c"]

# Environment variable to disable analytics in tests
ENV AIDER_ANALYTICS=false

# Prepare bash environment for conda activation by default on shell start
RUN echo "source /opt/conda/etc/profile.d/conda.sh && conda activate testbed" >> /root/.bashrc