FROM python:3-alpine
ENV TARGETARCH="linux-musl-x64"

RUN apk update && \
  apk upgrade && \
  apk add \
    bash \
    curl \
    gcc \
    git \
    git-lfs \
    icu-libs \
    jq \
    musl-dev \
    python3-dev \
    libffi-dev \
    openssl-dev \
    cargo \
    make \
    envsubst \
    docker=29.1.3-r0 \
    kubectl \
    yq \
    tar

# Install helm
RUN curl -Lo helm-v4.0.4-linux-amd64.tar.gz https://get.helm.sh/helm-v4.0.4-linux-amd64.tar.gz && \
  tar -zxvf helm-v4.0.4-linux-amd64.tar.gz && \
  install linux-amd64/helm /usr/local/bin && \
  rm helm-v4.0.4-linux-amd64.tar.gz && \
  rm -rf linux-amd64

# Install skaffold
RUN curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/v2.17.1/skaffold-linux-amd64 && \
  install skaffold /usr/local/bin/ && \
  skaffold config set --global collect-metrics false

# Install sops
RUN curl -Lo sops https://github.com/getsops/sops/releases/download/v3.11.0/sops-v3.11.0.linux.amd64 && \
  install sops /usr/local/bin/

# Install Azure CLI
RUN pip install --upgrade pip
RUN pip install azure-cli

WORKDIR /azp/

COPY ./start.sh ./
RUN chmod +x ./start.sh

# RUN adduser -D agent
# RUN chown agent ./
# USER agent

# Another option is to run the agent as root.
ENV AGENT_ALLOW_RUNASROOT="true"

ENTRYPOINT [ "./start.sh" ]
