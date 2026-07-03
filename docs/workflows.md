# Workflows & Automation

## GitHub Workflow Token

If you edit the CI workflows, your token needs the `workflow` scope:

```sh
gh auth status       # Check current scopes
gh auth login --scopes workflow
```

## Formatting

`nix fmt` runs whatever package the flake's `formatter` output points at
(`flake.nix`'s `formatter.${system}`), currently
[`nixfmt-tree`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/ni/nixfmt-tree/package.nix).
Three different tools are involved and it's easy to mix them up:

- **[`nixfmt`](https://github.com/NixOS/nixfmt)** — the official NixOS
  Foundation formatter. It formats a single file (or stdin), which makes
  it the right thing to point your editor's format-on-save at.
- **[`treefmt`](https://treefmt.com)** — a multi-language formatter
  orchestrator by numtide. It walks the whole repo tree and dispatches
  each file to the formatter configured for its type.
- **`nixfmt-tree`** — a small nixpkgs package that is *not*
  [the upstream version of Numtide's treefmt-nix](https://github.com/numtide/treefmt-nix)
  (that's a separate flake module numtide also publishes for configuring
  treefmt from Nix; unused here). It's just `treefmt` pre-wired to run
  `nixfmt` on every `*.nix` file, i.e. "zero-setup `nix fmt` for a Nix
  repo".

So `nix fmt` == treefmt-wide formatting using nixfmt under the hood, while
`nixfmt` on its own is the single-file tool for IDE integration.

The pre-commit hook (`.pre-commit-config.yaml`, run via
[`prek`](https://github.com/j178/prek)) invokes
`nix fmt -- --fail-on-change --no-cache`: it reformats any unformatted
files in place and fails the commit if anything changed, so re-stage and
commit again. treefmt has no dry-run/check flag that skips writing.

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
