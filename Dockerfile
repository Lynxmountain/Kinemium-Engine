FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# =========================
# Configurable environment
# =========================

# Ports / runtime
ENV SERVER_HOST=127.0.0.1
ENV SERVER_PORT=7777

# Paths
ENV APP_DIR=/app
ENV ROKIT_HOME=/root/.rokit
ENV PATH="${ROKIT_HOME}/bin:${PATH}"

# Runtime command (fully customizable)
ENV RUN_CMD="zune run game --server --headless --address ${SERVER_HOST} --port ${SERVER_PORT}"

# =========================
# Base dependencies
# =========================
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    wget \
    unzip \
    bash \
    && rm -rf /var/lib/apt/lists/*

# =========================
# Install Rokit
# =========================
RUN curl -fsSL https://raw.githubusercontent.com/CompeyDev/setup-rokit/main/install.sh | bash

# =========================
# App setup
# =========================
WORKDIR ${APP_DIR}
COPY . .

# Install tools via rokit
RUN rokit install --no-trust-check

# =========================
# Runtime
# =========================
CMD ["/bin/bash", "-lc", "eval \"$RUN_CMD\""]