# Use Ubuntu base image
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
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
    wget \
    && apt-get clean

# Set environment variables
ENV RUNNER_VERSION=2.326.0
ENV RUNNER_HOME=/runner

# Create a user to run the runner safely
RUN useradd -m -d ${RUNNER_HOME} -s /bin/bash runneruser

# Create runner directory
RUN mkdir -p ${RUNNER_HOME} && chown runneruser:runneruser ${RUNNER_HOME}
WORKDIR ${RUNNER_HOME}

# Download and extract runner
RUN curl -L -o actions-runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf actions-runner.tar.gz && \
    rm actions-runner.tar.gz && \
    chown -R runneruser:runneruser ${RUNNER_HOME}

# Switch to runner user
USER runneruser

# Add entrypoint
COPY entrypoint.sh .

ENTRYPOINT ["/runner/entrypoint.sh"]
