FROM nikolaik/python-nodejs:python3.9-nodejs20-slim
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Set environment variables required for chromium and puppeteer
ENV CHROME_BIN=/usr/bin/chromium \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    puppeteer_config=/app/metagpt/config/puppeteer-config.json

SHELL ["/bin/bash", "-c"]

# Install additional apt packages required by the project
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    git \
    chromium \
    fonts-liberation \
    fonts-noto-color-emoji \
    libxss1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app/metagpt

# Clone the repo and checkout specific commit in one layer to cache better
ARG COMMIT_SHA=0958cc333ee13d1ce5216ae0bdeaa53b5eacc6ea
RUN git clone https://github.com/FoundationAgents/MetaGPT.git /app/metagpt && \
    cd /app/metagpt && \
    git reset --hard ${COMMIT_SHA} && \
    chmod -R a+rw /app/metagpt

# Upgrade pip and install Python dependencies from requirements.txt and testing extras
RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir pytest pytest-asyncio pytest-cov pytest-mock pytest-html pytest-xdist pytest-timeout

# Install the package itself in editable mode (development mode)
RUN pip install --no-cache-dir -e .

# Install node global packages (mermaid-cli)
RUN npm install -g @mermaid-js/mermaid-cli

# Keep container running to allow manual testing or test execution by eval script
CMD ["tail", "-f", "/dev/null"]