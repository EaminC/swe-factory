# Use an Ubuntu base image with bash shell and consistent environment
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential system dependencies including git, python3.11, pip, curl, and build tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    software-properties-common \
    libffi-dev \
    libssl-dev \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    python3-pip \
    python3-setuptools \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to ensure smooth installation of packages
RUN python3.11 -m pip install --upgrade pip

# Set /bin/bash as the default shell explicitly (mostly ensured by ubuntu base)
SHELL ["/bin/bash", "-c"]

# Set working directory to /testbed
WORKDIR /testbed/

# Clone the target repository and checkout the specified commit SHA
RUN git clone https://github.com/MLSysOps/MLE-agent.git /testbed && \
    cd /testbed && \
    git checkout 8109d8b905bb4aac4de6258516a966abaf2147f5

# Install required python packages:
# 1. Install the repository in editable mode to allow local code changes to be effective.
# 2. Install explicit version dependencies.
# 3. Install unspecified version dependencies.
RUN python3.11 -m pip install -e . && \
    python3.11 -m pip install "openai~=1.34.0" "pandas~=2.2.2" "numexpr~=2.10.1" "bottleneck~=1.4.0" \
        "google-api-python-client~=2.143.0" "google-auth-httplib2~=0.2.0" "google-auth-oauthlib~=1.2.1" && \
    python3.11 -m pip install rich click pyyaml fastapi uvicorn requests chromadb onnxruntime questionary tavily-python instructor setuptools

# Ensure pip caches are cleared to keep image size smaller
RUN python3.11 -m pip cache purge

# Add a note for bash users to activate python3.11 environment if needed (python installed system-wide)
RUN echo "Use python3.11 and pip with the commands 'python3.11' and 'python3.11 -m pip'."

# No CMD or ENTRYPOINT specified as requested, tests will be run externally.