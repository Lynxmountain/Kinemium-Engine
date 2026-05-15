FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# Basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    wget \
    unzip \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Install Rokit (verify official installer URL if needed)
RUN curl -fsSL https://raw.githubusercontent.com/CompeyDev/setup-rokit/main/install.sh | bash

# Ensure rokit is available in PATH (adjust if installer uses different path)
ENV PATH="/root/.rokit/bin:${PATH}"

# Copy project into container
WORKDIR /app
COPY . .

# Install tools via rokit
RUN rokit install --no-trust-check

# Run headless tests
CMD ["zune", "run", "game", "--server", "--headless"]