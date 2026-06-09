# Use Python 3.10 with Node.js 20 slim image for compatibility with paddlepaddle and other dependencies
FROM --platform=linux/x86_64 nikolaik/python-nodejs:python3.10-nodejs20-slim

ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies including git, chromium, fonts, build tools for building wheels, and certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    chromium \
    fonts-liberation \
    ca-certificates \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables required by metagpt and puppeteer
ENV CHROME_BIN=/usr/bin/chromium \
    puppeteer_config=/app/metagpt/config/puppeteer-config.json \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Set working directory
WORKDIR /testbed/

# Clone repository and reset to specific commit provided as build argument
ARG COMMIT_SHA=ab846f65e481a655b791959eb0f89fb4b1c84128

RUN git clone https://github.com/Geekan/MetaGPT.git . \
 && git reset --hard ${COMMIT_SHA} \
 && git remote remove origin

# Create and activate virtual environment for dependency isolation
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip, setuptools, and wheel to latest stable versions
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install python dependencies pinned in requirements.txt which ensures version constraints
# Then install editable project with test extras
# This avoids pip resolver complexity by relying on pinned versions in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt \
 && pip install --no-cache-dir -e .[test]

# Globally install mermaid-cli for node usage as required
RUN npm install -g @mermaid-js/mermaid-cli

# Create directory for Metagpt config to be mounted or created at runtime
RUN mkdir -p /root/.metagpt

# Ensure virtualenv activation on bash shell start for convenience
RUN echo "source /opt/venv/bin/activate" >> /root/.bashrc

# Default to bash shell
CMD ["/bin/bash"]