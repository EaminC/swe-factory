# Update base image to python 3.10 version to ensure compatibility with paddlepaddle >= 3.10 python requirement
FROM --platform=linux/x86_64 nikolaik/python-nodejs:python3.10-nodejs20-slim

ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Install system dependencies: git, chromium (headless browser), and fonts for rendering
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    chromium \
    fonts-liberation \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for chromium and puppeteer config as per context info
ENV CHROME_BIN=/usr/bin/chromium \
    puppeteer_config=/app/metagpt/config/puppeteer-config.json \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Create working directory
WORKDIR /testbed/

# Clone the repo and checkout to specific commit arg passed during build
ARG COMMIT_SHA=ab846f65e481a655b791959eb0f89fb4b1c84128

RUN git clone https://github.com/Geekan/MetaGPT.git . \
 && git reset --hard ${COMMIT_SHA} \
 && git remote remove origin

# Install python packages in an isolated environment using python venv
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip, setuptools, wheel
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install python dependencies pinned in requirements.txt including aiohttp, pandas, PyYAML, scikit_learn, rich, etc
# Then install the editable project and test extras (test extras may include paddlepaddle which needs python >=3.10)
RUN pip install --no-cache-dir -r requirements.txt \
 && pip install --no-cache-dir -e .[test]

# Install puppeteer dependency globally via npm
RUN npm install -g @mermaid-js/mermaid-cli

# Prepare metagpt user config directory, can be populated at test runtime
RUN mkdir -p /root/.metagpt

# Activate venv by default via bashrc for interactive sessions
RUN echo "source /opt/venv/bin/activate" >> /root/.bashrc

# Default to bash shell
CMD ["/bin/bash"]