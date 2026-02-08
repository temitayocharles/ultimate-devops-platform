# Ultimate DevOps Dev Container

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
docker build -t temitayocharles/ultimate-devops:latest .
```

## Run (Mac/Linux)

### Option A: Use host Docker socket
```bash
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $HOME/.kube:/home/devops/.kube \
  -v $HOME/.aws:/home/devops/.aws \
  -v $HOME/devops-work:/home/devops/work \
  temitayocharles/ultimate-devops:latest
```

### Option B: Docker-in-Docker
```bash
docker run --rm -it --privileged \
  -e ENABLE_DOCKERD=true \
  -v $HOME/devops-work:/home/devops/work \
  temitayocharles/ultimate-devops:latest
```

## Run (Windows / WSL2)

```bash
docker run --rm -it ^
  -v //var/run/docker.sock:/var/run/docker.sock ^
  -v %USERPROFILE%\\.kube:/home/devops/.kube ^
  -v %USERPROFILE%\\.aws:/home/devops/.aws ^
  -v %USERPROFILE%\\devops-work:/home/devops/work ^
  temitayocharles/ultimate-devops:latest
```

## Notes

- This image is intended as a **portable dev workstation**.
- For Docker Engine inside container, use `--privileged` and set `ENABLE_DOCKERD=true`.
- Persist data by mounting `/home/devops`.

## Optional UI

If you want a simple UI companion, we can add a minimal web dashboard and ship a second image (or serve static docs inside the container).
