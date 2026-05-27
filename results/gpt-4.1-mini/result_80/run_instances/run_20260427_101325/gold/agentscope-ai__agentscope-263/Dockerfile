FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies and utilities
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-distutils \
    python3-venv \
    curl \
    build-essential \
    wget \
    locales \
    locales-all \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Use the default python3 (likely python3.10) included in Ubuntu 22.04
# No need to update-alternatives because python3 is already correctly set

# Install pip for python3
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3

# Create a virtual environment named testbed
RUN python3 -m venv /opt/testbed

# Activate the virtual environment and upgrade pip
RUN /opt/testbed/bin/pip install --upgrade pip

# Set environment variables for virtual env
ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

WORKDIR /testbed/

# Clone the repository and checkout the specific commit SHA
RUN git clone https://github.com/agentscope-ai/agentscope.git /testbed \
    && cd /testbed \
    && git reset --hard f761cf215fbd1f0a1e57eb2d073229628b77f462 \
    && git remote remove origin

# Install the repository in editable mode with full extras and test dependencies
RUN pip install -e ".[full]" \
    && pip install pytest pytest-cov pre-commit coverage

# Set shell to bash and source virtualenv automatically for interactive sessions
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc

# Expose environment variables placeholders (to be set at container runtime)
ENV OPENAI_API_KEY=""
ENV OPENAI_ORGANIZATION=""

# Default shell to bash explicitly
SHELL ["/bin/bash", "-c"]