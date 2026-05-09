# Workflows & Automation

## GitHub Workflow Token

If you edit the CI workflows, your token needs the `workflow` scope:

```sh
gh auth status       # Check current scopes
gh auth login --scopes workflow
```

## Facter

Generate a hardware report for a new system:

```sh
sudo nix run \
  --option experimental-features "nix-command flakes" \
  --option extra-substituters https://numtide.cachix.org \
  --option extra-trusted-public-keys numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE= \
  github:numtide/nixos-facter -- -o facter.json
```

Place the output in `systems/<arch>/<host>/facter.json`.
