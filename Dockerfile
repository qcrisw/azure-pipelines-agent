FROM python:3-alpine
ENV TARGETARCH="linux-musl-x64"

RUN apk update && \
  apk upgrade && \
  apk add bash curl gcc git icu-libs jq musl-dev python3-dev libffi-dev openssl-dev cargo make envsubst

# Install Azure CLI
RUN pip install --upgrade pip
RUN pip install azure-cli


# Install latest version of git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
apt-get install -y --no-install-recommends git-lfs=3.1.2 && \
rm -rf /var/lib/apt/lists/*

# Install docker binary:
ARG docker_url=https://download.docker.com/linux/static/stable/x86_64
ARG docker_version=28.4.0
RUN curl -fsSL $docker_url/docker-$docker_version.tgz | \
      tar zxvf - --strip 1 -C /usr/bin docker/docker

# Install kubectl binary:
ARG kubectl_url=https://storage.googleapis.com/kubernetes-release/release
RUN curl -fsSL $kubectl_url/`curl -s $kubectl_url/stable.txt`/bin/linux/amd64/kubectl \
  -o /usr/bin/kubectl && \
  chmod +x /usr/bin/kubectl && \
  kubectl version --client


WORKDIR /azp/

COPY ./start.sh ./
RUN chmod +x ./start.sh

# RUN adduser -D agent
# RUN chown agent ./
# USER agent

# Another option is to run the agent as root.
ENV AGENT_ALLOW_RUNASROOT="true"

ENTRYPOINT [ "./start.sh" ]
