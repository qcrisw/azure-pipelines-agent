FROM ubuntu:18.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        git \
        iputils-ping \
        libcurl4 \
        libicu60 \
        libunwind8 \
        netcat \
        libssl1.0 \
        wget \
	gettext-base zip unzip sudo

RUN wget -q https://github.com/mikefarah/yq/releases/download/v4.14.2/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

RUN apt-get install -y --no-install-recommends git-lfs && \
    git lfs install && \
    rm -r /var/lib/apt/lists/*

WORKDIR /azp

# Install docker binary:
ARG docker_url=https://download.docker.com/linux/static/stable/x86_64
ARG docker_version=18.03.1-ce
RUN curl -fsSL $docker_url/docker-$docker_version.tgz | \
	tar zxvf - --strip 1 -C /usr/bin docker/docker

# Install kubectl binary:
ARG kubectl_url=https://storage.googleapis.com/kubernetes-release/release
RUN curl -fsSL $kubectl_url/`curl -s $kubectl_url/stable.txt`/bin/linux/amd64/kubectl \
  -o /usr/bin/kubectl && \
  chmod +x /usr/bin/kubectl && \
  kubectl version --client

# Install the Azure CLI binary with the DevOps extension
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    az --version && \
    az extension add -n azure-devops && \
    az extension list

ARG TARGETARCH=amd64
ARG AGENT_VERSION=2.194.0

RUN if [ "$TARGETARCH" = "amd64" ]; then \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz; \
    else \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-${TARGETARCH}-${AGENT_VERSION}.tar.gz; \
    fi; \
    curl -LsS "$AZP_AGENTPACKAGE_URL" | tar -xz

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]
