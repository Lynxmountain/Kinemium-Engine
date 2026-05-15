FROM ubuntu:26.04
ENV DEBIAN_FRONTEND=noninteractive

ENV APP_DIR=/app
ENV ROKIT_HOME=/root/.rokit
ENV PATH="${ROKIT_HOME}/bin:${PATH}"

# Defaults (overridable at runtime with -e)
ENV address=0.0.0.0
ENV port=7777

RUN apt-get update && apt-get install -y \
    curl git ca-certificates wget unzip bash \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://raw.githubusercontent.com/CompeyDev/setup-rokit/main/install.sh | bash

WORKDIR ${APP_DIR}
COPY . .

RUN rokit install --no-trust-check

EXPOSE ${port}

CMD ["/bin/bash", "-lc", "zune run game --server --headless --address \"$address\" --port \"$port\""]