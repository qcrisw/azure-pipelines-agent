FROM python:3-alpine
ENV TARGETARCH="linux-musl-x64"

RUN apk update && \
  apk upgrade && \
  apk add bash curl gcc git git-lfs icu-libs jq musl-dev python3-dev libffi-dev openssl-dev cargo make envsubst docker=29.1.3-r0 kubectl

# Install Skaffold
RUN curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
  install skaffold /usr/local/bin/

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
