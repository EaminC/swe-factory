# Base image with Python 3.12 (within the required range 3.10-3.13)
FROM --platform=linux/x86_64 python:3.12-slim-bookworm

# Set environment variables to avoid interactive prompts
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PATH="/root/.local/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    curl \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install uv (package manager used by the project)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && uv --version

# Set up the working directory
WORKDIR /testbed

# Clone the repository and checkout the specific commit
RUN git clone https://github.com/crewAIInc/crewAI.git /testbed \
    && git reset --hard cb522cf5005f856b21c6976e8d94709ae4f9c3f3 \
    && git remote remove origin

# Create virtual environment
RUN uv venv /testbed/.venv --python 3.12

# Use uv pip to install the project in development mode with main dependencies
# uv pip will use the virtual environment automatically
RUN uv pip install -e .

# Install optional dependencies (tools and embeddings)
RUN uv pip install "crewai[tools,embeddings]"

# Install test/development dependencies using uv sync (which handles dev-dependencies)
# The --dev flag installs development dependencies from pyproject.toml
RUN cd /testbed && uv sync --dev

# Set up environment variables for testing (empty values for safety)
ENV OPENAI_API_KEY=""
ENV SERPER_API_KEY=""
ENV OTEL_SDK_DISABLED="true"

# Ensure the virtual environment is activated in bash sessions
RUN echo "source /testbed/.venv/bin/activate" >> /root/.bashrc

# Set the default command to bash with the virtual environment activated
CMD ["/bin/bash", "-c", "source /testbed/.venv/bin/activate && exec /bin/bash"]