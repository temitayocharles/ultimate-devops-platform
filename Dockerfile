FROM debian:bookworm AS tools

ARG KUBECTL_VERSION=v1.30.3
ARG HELM_VERSION=v3.15.4
ARG K9S_VERSION=v0.32.5
ARG TERRAFORM_VERSION=1.8.5
ARG TERRAGRUNT_VERSION=v0.66.3
ARG VAULT_VERSION=1.17.3
ARG PACKER_VERSION=1.10.2
ARG YQ_VERSION=v4.44.3
ARG KUSTOMIZE_VERSION=v5.4.2
ARG KIND_VERSION=v0.24.0
ARG K3D_VERSION=v5.6.0
ARG ARGOCD_VERSION=v2.11.7
ARG FLUX_VERSION=2.3.0
ARG GO_VERSION=1.22.6
ARG NODE_VERSION=20.15.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl unzip tar gzip xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/tools

# kubectl
RUN curl -fsSL -o kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x kubectl

# helm
RUN curl -fsSL -o helm.tar.gz "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \
    && tar -xzf helm.tar.gz \
    && mv linux-amd64/helm helm \
    && chmod +x helm \
    && rm -rf linux-amd64 helm.tar.gz

# k9s
RUN curl -fsSL -o k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" \
    && tar -xzf k9s.tar.gz k9s \
    && chmod +x k9s \
    && rm -f k9s.tar.gz

# terraform
RUN curl -fsSL -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip terraform.zip terraform \
    && chmod +x terraform \
    && rm -f terraform.zip

# terragrunt
RUN curl -fsSL -o terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
    && chmod +x terragrunt

# vault
RUN curl -fsSL -o vault.zip "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" \
    && unzip vault.zip vault \
    && chmod +x vault \
    && rm -f vault.zip

# packer
RUN curl -fsSL -o packer.zip "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" \
    && unzip packer.zip packer \
    && chmod +x packer \
    && rm -f packer.zip

# yq
RUN curl -fsSL -o yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" \
    && chmod +x yq

# jq (static)
RUN curl -fsSL -o jq "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64" \
    && chmod +x jq

# kustomize
RUN curl -fsSL -o kustomize.tar.gz "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" \
    && tar -xzf kustomize.tar.gz kustomize \
    && chmod +x kustomize \
    && rm -f kustomize.tar.gz

# kind
RUN curl -fsSL -o kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64" \
    && chmod +x kind

# k3d
RUN curl -fsSL -o k3d "https://github.com/k3d-io/k3d/releases/download/${K3D_VERSION}/k3d-linux-amd64" \
    && chmod +x k3d

# argocd
RUN curl -fsSL -o argocd "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64" \
    && chmod +x argocd

# flux
RUN curl -fsSL "https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz" \
    | tar -xz flux \
    && chmod +x flux

# go
RUN curl -fsSL -o go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
    && mkdir -p /opt/go \
    && tar -xzf go.tar.gz -C /opt \
    && rm -f go.tar.gz

# node
RUN curl -fsSL -o node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" \
    && mkdir -p /opt/node \
    && tar -xJf node.tar.xz -C /opt/node --strip-components=1 \
    && rm -f node.tar.xz

# awscli v2 (arch-aware)
RUN ARCH=$(uname -m) \
    && if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
         AWS_PKG="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"; \
       else \
         AWS_PKG="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"; \
       fi \
    && curl -fsSL -o awscliv2.zip "$AWS_PKG" \
    && unzip awscliv2.zip \
    && ./aws/install --install-dir /opt/aws-cli --bin-dir /opt/tools \
    && rm -rf aws awscliv2.zip

FROM debian:bookworm-slim

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=/usr/local/bin:/usr/bin:/bin:/opt/go/bin:/opt/node/bin

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates curl git zsh openssh-client sudo adduser \
    python3 python3-pip make unzip \
    docker.io iptables iproute2 tini \
    && rm -rf /var/lib/apt/lists/*

RUN /usr/sbin/adduser --disabled-password --gecos "" devops \
    && /usr/sbin/adduser devops docker \
    && echo "devops ALL=(ALL) NOPASSWD:/usr/sbin/dockerd" > /etc/sudoers.d/devops \
    && chmod 0440 /etc/sudoers.d/devops

COPY --from=tools /opt/tools/* /usr/local/bin/
COPY --from=tools /opt/go /opt/go
COPY --from=tools /opt/node /opt/node
COPY --from=tools /opt/aws-cli /opt/aws-cli

RUN ln -sf /opt/aws-cli/v2/current/bin/aws /usr/local/bin/aws \
    && ln -sf /opt/aws-cli/v2/current/bin/aws_completer /usr/local/bin/aws_completer

COPY ui /opt/ui

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /home/devops
USER devops

VOLUME ["/home/devops"]

EXPOSE 8080

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["zsh"]
