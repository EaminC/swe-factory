# Base image with bash and stable Ubuntu version
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system utilities first (minimal)
RUN apt update && apt install -y wget git curl tzdata locales locales-all && rm -rf /var/lib/apt/lists/*

# Install Python related packages separately to reduce peak memory usage
RUN apt update && apt install -y python3.10 python3.10-venv python3.10-distutils python3-pip && rm -rf /var/lib/apt/lists/*

# Install build-essential in a separate step to reduce memory pressure
RUN apt update && apt install -y build-essential && rm -rf /var/lib/apt/lists/*

# Upgrade pip globally
RUN python3.10 -m pip install --upgrade pip

# Set working directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/AntonOsika/gpt-engineer /testbed && \
    cd /testbed && \
    git reset --hard 35c35b3ffab89cfa0eb714f5d5c28c6eb2aa7faa

# Create Python virtual environment and upgrade pip inside it
RUN python3.10 -m venv /testbed/venv && \
    source /testbed/venv/bin/activate && \
    pip install --upgrade pip

# Install Python dependencies inside virtual environment, including editable install of the repo and test requirements
RUN source /testbed/venv/bin/activate && \
    pip install -r requirements.txt && \
    pip install -e . && \
    pip install pytest pytest-cov

# Automatically activate virtual environment on container start (for interactive/bash use)
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Set environment variables so venv python and tools are default
ENV VIRTUAL_ENV=/testbed/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"