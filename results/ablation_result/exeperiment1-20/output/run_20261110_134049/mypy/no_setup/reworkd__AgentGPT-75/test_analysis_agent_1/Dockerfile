# Use Ubuntu 22.04 as base image for stable and bash-supported environment
FROM --platform=linux/x86_64 ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
SHELL ["/bin/bash", "-c"]

# Install essential system packages: git, curl, nodejs >=18, npm, and other utilities
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

# Set locale to UTF-8 (important for Node and other tooling)
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Node.js 18.x LTS and npm from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Create working directory
WORKDIR /testbed/

# Clone the repository and checkout the specified commit
ARG REPO=https://github.com/reworkd/AgentGPT.git
ARG COMMIT_SHA=3caa8faa22d8c820bfd0bfb663be5035938b528b
RUN git clone $REPO . \
    && git checkout $COMMIT_SHA

# Install dependencies via npm
# Use 'npm ci' if package-lock.json exists for reproducible install; fallback to 'npm install' otherwise
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Run prisma generate as postinstall script in package.json calls it, but explicitly here for safety
RUN npx prisma generate || true

# Set environment variables placeholders (no secret values, just placeholders)
ENV NODE_ENV=development
ENV NEXTAUTH_SECRET=changeme
ENV NEXTAUTH_URL=http://localhost:3000
ENV DATABASE_URL=file:./dev.db
ENV OPENAI_API_KEY=changeme

# Do not install Python, Python dependencies, or attempt tests as no Python test file is present.

# Permissions fix
RUN chmod -R 777 /testbed/

# Expose port (not required for tests but useful if running dev server manually)
EXPOSE 3000

# Use bash shell explicitly
CMD ["/bin/bash"]