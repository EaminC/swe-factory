# Use Ubuntu 22.04 base image for stability and bash compatibility
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system packages
RUN apt update && apt install -y \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    locales \
    tzdata \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Configure locale for UTF-8 support
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Node.js 22.x (upgrade from 18) and latest npm
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Set working directory inside container before cloning to avoid layer issues
RUN mkdir -p /testbed
WORKDIR /testbed

# Clone repository and checkout specific commit in a single RUN to reduce layers
ARG REPO=https://github.com/reworkd/AgentGPT.git
ARG COMMIT_SHA=3caa8faa22d8c820bfd0bfb663be5035938b528b
RUN git clone "$REPO" /testbed && cd /testbed && git checkout "$COMMIT_SHA"

# Install npm dependencies using npm ci if lock file exists, fallback to npm install
RUN cd /testbed && if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Explicitly run prisma generate to generate client
RUN cd /testbed && npx prisma generate || true

# Set placeholder environment variables required by the app
ENV NODE_ENV=development
ENV NEXTAUTH_SECRET=changeme
ENV NEXTAUTH_URL=http://localhost:3000
ENV DATABASE_URL=file:./dev.db
ENV OPENAI_API_KEY=changeme

# Avoid recursive chmod on entire directory to reduce resource usage
# Set directory ownership to root (default) with standard permissions (no excessive chmod)
# This assumes container user runs as root and permissions are sufficient

# Expose port 3000 (for running the Next.js app manually if desired)
EXPOSE 3000

# Default to bash shell
CMD ["/bin/bash"]