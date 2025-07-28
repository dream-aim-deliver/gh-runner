# Use Ubuntu base image
FROM ubuntu:22.04

# Prevent any interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    sudo \
    git \
    jq \
    unzip \
    gnupg2 \
    ca-certificates \
    libicu70 \
    libkrb5-3 \
    libssl3 \
    libunwind8 \
    libcurl4 \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install GitHub CLI (gh) official repo setup
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV RUNNER_VERSION=2.326.0

# Create runner user and directory
RUN useradd -m -d /home/runneruser/runner -s /bin/bash runneruser

# Allow runneruser to sudo without password
RUN echo "runneruser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/runneruser \
  && chmod 440 /etc/sudoers.d/runneruser

# Setup docker
RUN sudo apt-get update && sudo apt-get install -y \
    ca-certificates curl gnupg lsb-release && \
  sudo install -m 0755 -d /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
   | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
     https://download.docker.com/linux/ubuntu jammy stable" \
   | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  sudo apt-get update && \
  sudo apt-get install -y docker-ce-cli && \
  sudo apt-get clean && rm -rf /var/lib/apt/lists/*

ARG DOCKER_GID
RUN groupadd -g $DOCKER_GID docker || true && usermod -aG docker runneruser

# Fix permissions just in case
RUN chown -R runneruser:runneruser /home/runneruser/runner

WORKDIR /home/runneruser/runner

# Download and extract runner
RUN curl -L -o actions-runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner.tar.gz \
    && rm actions-runner.tar.gz \
    && chown -R runneruser:runneruser /home/runneruser/runner

USER runneruser

# ARGs for registration, passed at build time
ARG REPO_URL
ARG RUNNER_TOKEN
ARG RUNNER_NAME
ARG RUNNER_LABELS

# Register the runner at build time
RUN ./config.sh --unattended --url ${REPO_URL} --token ${RUNNER_TOKEN} --name ${RUNNER_NAME} --labels ${RUNNER_LABELS}

# Entrypoint to start the runner
ENTRYPOINT ["./run.sh"]
