FROM ubuntu:26.04
ENV DEBIAN_FRONTEND=noninteractive

# =========================
# Configurable environment
# =========================
ENV APP_DIR=/app
ENV ROKIT_HOME=/root/.rokit
ENV PATH="${ROKIT_HOME}/bin:${PATH}"

# Runtime defaults (overridable at runtime with -e)
ENV address=0.0.0.0
ENV port=7777
ENV PLAYIT_SECRET=""
ENV USE_PLAYIT=false

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
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# =========================
# Install Rokit
# =========================
RUN curl -fsSL https://raw.githubusercontent.com/CompeyDev/setup-rokit/main/install.sh | bash

# =========================
# Install playit.gg (optional, only runs if USE_PLAYIT=true)
# =========================
RUN curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null \
    && echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/v0 . /" | tee /etc/apt/sources.list.d/playit-cloud.list \
    && apt-get update && apt-get install -y playit \
    && rm -rf /var/lib/apt/lists/*

# =========================
# App setup
# =========================
WORKDIR ${APP_DIR}
COPY . .

RUN rokit install --no-trust-check

# =========================
# Runtime
# =========================
EXPOSE ${port}

CMD ["/bin/bash", "-lc", "\
    if [ \"$USE_PLAYIT\" = \"true\" ] && [ -n \"$PLAYIT_SECRET\" ]; then \
    echo '[playit] Starting playit.gg tunnel...' && \
    playit --secret \"$PLAYIT_SECRET\" & \
    elif [ \"$USE_PLAYIT\" = \"true\" ] && [ -z \"$PLAYIT_SECRET\" ]; then \
    echo '[playit] USE_PLAYIT=true but PLAYIT_SECRET is not set, skipping.' ; \
    fi && \
    echo '[engine] Starting Kinemium server...' && \
    zune run game --server --headless --address \"$address\" --port \"$port\" \
    "]