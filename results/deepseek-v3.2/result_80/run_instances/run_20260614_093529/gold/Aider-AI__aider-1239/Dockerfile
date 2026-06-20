FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install system dependencies
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    ca-certificates \
    curl \
    locales \
    tzdata \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up Python environment (using system Python instead of Conda for simplicity)
RUN python3 -m pip install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /testbed

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/Aider-AI/aider.git /testbed && \
    git reset --hard 301c4265b76a5b8c4a939acb59314e091cacebec && \
    git remote remove origin

# Create and activate virtual environment
RUN python3 -m venv /testbed/venv
ENV PATH="/testbed/venv/bin:$PATH"

# Install dependencies from requirements.txt
RUN pip install -r requirements.txt

# Install development dependencies (includes pytest and testing tools)
RUN pip install -r requirements/requirements-dev.txt

# Install the package in development mode
RUN pip install -e .

# Set environment variables for API keys (empty by default)
ENV OPENAI_API_KEY=""
ENV ANTHROPIC_API_KEY=""

# Ensure the virtual environment is activated in bash sessions
RUN echo "source /testbed/venv/bin/activate" >> /root/.bashrc

# Set a default command to keep the container running
CMD ["/bin/bash"]