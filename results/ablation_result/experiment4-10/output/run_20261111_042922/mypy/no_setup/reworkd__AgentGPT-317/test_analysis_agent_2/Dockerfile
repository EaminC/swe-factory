FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system dependencies including git, curl, bash-completion, and others
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    pkg-config \
    libsqlite3-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js >=18 LTS (use NodeSource official setup)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && node --version \
    && npm --version

# Set environment variables as per context (can be overridden at runtime)
ENV NODE_ENV=development \
    NEXTAUTH_SECRET=changeme \
    NEXTAUTH_URL=http://localhost:3000 \
    DATABASE_URL=file:./db.sqlite \
    OPENAI_API_KEY=changeme

# Set work directory
WORKDIR /testbed/

# Clone the repository and checkout the specific commit
ARG REPO=https://github.com/reworkd/AgentGPT.git
ARG COMMIT_SHA=cff1554f488d75f02ae7acbe5a64f107103da389

RUN git clone $REPO . \
    && git reset --hard $COMMIT_SHA

# Install project dependencies using npm
RUN npm install

# Run the sqlite setup script and prisma migrations
# Prisma CLI is installed as part of node_modules/.bin/prisma after npm install
RUN chmod +x ./prisma/useSqlite.sh && ./prisma/useSqlite.sh
RUN npx prisma db push

# Install the package in development mode by linking it
RUN npm link

# Change default shell to bash for scripts and runtime
RUN echo "cd /testbed" >> ~/.bashrc

# Default workdir remains /testbed
WORKDIR /testbed/