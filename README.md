# Ultimate DevOps Dev Container


## Start Here
- Read [START_HERE.md](START_HERE.md) for the chronological playbook.

Ready-to-use DevOps workstation in a container. Ships with Kubernetes, Terraform, Docker CLI/Engine, Vault CLI, AWS CLI, and core tooling.

## What’s Included

Core tools (preinstalled):
- `kubectl`, `helm`, `k9s`
- `terraform`, `terragrunt`, `packer`
- `vault`, `argocd`, `flux`
- `kind`, `k3d`, `kustomize`
- `aws` CLI (v2), `jq`, `yq`
- `git`, `zsh`, `python3`, `node`, `go`
- `docker` engine + CLI

## Build

```bash
docker build -t temitayocharles/ultimate-devops-platform:latest .
```

## Run (Mac/Linux)

### Option A: Use host Docker socket (recommended)
```bash
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $HOME/.kube:/home/devops/.kube \
  -v $HOME/.aws:/home/devops/.aws \
  -v $HOME/devops-work:/home/devops/work \
  temitayocharles/ultimate-devops-platform:latest
```

### Option B: Docker-in-Docker (DinD)
```bash
docker run --rm -it --privileged \
  -e ENABLE_DOCKERD=true \
  -v $HOME/devops-work:/home/devops/work \
  temitayocharles/ultimate-devops-platform:latest
```

## Run (Windows / WSL2)

```bash
docker run --rm -it ^
  -v //var/run/docker.sock:/var/run/docker.sock ^
  -v %USERPROFILE%\\.kube:/home/devops/.kube ^
  -v %USERPROFILE%\\.aws:/home/devops/.aws ^
  -v %USERPROFILE%\\devops-work:/home/devops/work ^
  temitayocharles/ultimate-devops-platform:latest
```

## Optional UI + Docker-in-Docker (single command)

Enable the UI and auto-start Docker Engine inside the container:

```bash
docker run --rm -it \
  --privileged \
  -e DEVOPS_UI=1 \
  -p 8080:8080 \
  -v devops-home:/home/devops \
  temitayocharles/ultimate-devops-platform:latest
```

## Notes

- This image is intended as a **portable dev workstation**.
- For Docker Engine inside container, use `--privileged` and set `ENABLE_DOCKERD=true` (or `DEVOPS_UI=1`).
- The container runs as a **non-root** user by default. `sudo` is limited to `/usr/sbin/dockerd`.
- For best security, prefer the host Docker socket and avoid `--privileged` unless required.
- Persist data by mounting `/home/devops`.
