FROM --platform=linux/x86_64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, python3.11, pip, build tools, and necessary libs
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3-distutils \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and setuptools to ensure smooth installs
RUN python3.11 -m pip install --upgrade pip setuptools

# Create a virtual environment named 'testbed'
RUN python3.11 -m venv /opt/testbed

# Activate venv and install required dependencies
RUN /bin/bash -c "source /opt/testbed/bin/activate && \
    pip install --upgrade pip setuptools && \
    pip install 'openai~=1.34.0' \
                'pandas~=2.2.2' \
                'numexpr~=2.10.1' \
                'bottleneck~=1.4.0' \
                'google-api-python-client~=2.143.0' \
                'google-auth-httplib2~=0.2.0' \
                'google-auth-oauthlib~=1.2.1' \
                rich click pyyaml requests chromadb onnxruntime questionary tavily-python instructor setuptools && \
    pip cache purge"

# Clone the repository into /testbed and set workdir
WORKDIR /testbed

RUN git clone https://github.com/MLSysOps/MLE-agent.git /testbed

# Checkout the specific commit SHA provided
RUN git reset --hard 71fab2dc51f9944a521a403af1924e0cf5bef76b

# Install the target repository in editable mode using virtual env's pip
RUN /bin/bash -c "source /opt/testbed/bin/activate && pip install -e ."

# Ensure that the virtual environment is activated by default when using bash
RUN echo "source /opt/testbed/bin/activate" >> /root/.bashrc
ENV VIRTUAL_ENV=/opt/testbed
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Default shell to /bin/bash to avoid runtime issues
CMD ["/bin/bash"]