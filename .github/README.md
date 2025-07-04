# Mirza's Awesome Nix Config

<!-- ![https://www.reddit.com/r/NixOS/comments/16ky6ez/nixos_logo_variations/](https://preview.redd.it/nixos-logo-variations-v0-yr95r3otvsob1.png?width=1024&format=png&auto=webp&s=d0a14a613101103a31844ab60a711128286468a2) -->

![https://www.reddit.com/r/NixOS/comments/16ky6ez/nixos_logo_variations/](nixos-logo-cloudy.webp)

## Initial setup

Clone the repository into your local `.config` directory.

```sh
git clone https://github.com/arunoruto/flake ~/.config/flake
```

If it deviates from this, set the env-variable `FLAKE` to the new path.

### NixOS

When first time trying to install the flake, you need to run:

```sh
sudo nixos-rebuild switch --flake ./#<device-name> --accept-flake-config
```

### Home Manager

Like NixOS, home-manager can be also updated from the flake file like follows:

```sh
home-manager switch --flake ./#<username> --accept-flake-config
```

The flake specifications are surrounded by quotes, since some shells (e.g. zsh) are complaining due to the # symbol.

#### None NixOS Systems

If nix is used as a package manager on a system, home manager can be installed using `nix run`:

```sh
nix --experimental-features 'nix-command flakes' --accept-flake-config run nixpkgs#home-manager -- switch --flake .#<username>
```

## Nix Helper

After the initial setup, the system can be configured using the [`nh`](https://github.com/viperML/nh) command.
It is important to provide the `FLAKE` variable in the system, and it needs to point to the flake's repository.
This can be specified per system in its `configuration.nix` under `environment.sessionVariables`.
If not, it can be appended to the commands.

### NixOS

```sh
nh os switch # if the FLAKE variable is set, or
nh os switch ./#<device-name>
```

### Home Manager

```sh
nh home switch # if the FLAKE variable is set, or
nh home switch ./#<username>
```

## Facter

Generate a `facter.json` file for a system and place it in the correct host path:

```sh
sudo nix run \
  --option experimental-features "nix-command flakes" \
  --option extra-substituters https://numtide.cachix.org \
  --option extra-trusted-public-keys numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE= \
  github:numtide/nixos-facter -- -o facter.json
```

## Nixvim

Nixvim is the nix way to configure neovim.
More information can be found in the [nvim README](../modules/home-manager/server/shell/nvim/README.md).

## Git Fetchers

When using a git fetcher, you need the commit hash/revision/tag/version and the corresponding hash.
You can either fetch everything with an empty hash, let the build error out and copy the hash from the logs,
or use `nix-prefetch-git`:

```sh
nix run nixpkgs#nix-prefetch-git <URL>
```

To prefetch candy-icons, you would call:

```sh
nix run nixpkgs#nix-prefetch-git https://github.com/EliverLara/candy-icons
```

## Workflows

If edits are made to the workflow(s), a token with the `workflow` scope is needed:

```sh
gh auth status # Check current scopes in token
gh auth login --scopes workflow # Request a new one with the workflow scope
```

## Helpful Material

### Setup

Some nice intro is provided by [thiscute.world](https://nixos-and-flakes.thiscute.world/).

[vimjoyer](https://www.youtube.com/@vimjoyer) has some amazing videos about nix and other nix related stuff:

- [Nix explained from the ground up](https://www.youtube.com/watch?v=5D3nUU1OVx8)
  is a really nice introduction to Nix
- [NixOS: Everything Everywhere All At Once](https://www.youtube.com/watch?v=CwfKlX3rA6E)
  NixOS from a beginner's perspective, kinda
- [Ultimate NixOS Guide | Flakes | Home-manager](https://www.youtube.com/watch?v=a67Sv4Mbxmc)
  gives a good introduction for beginners, and introduces flakes and how to use them to configure the system
- [Modularize NixOS and Home Manager | Great Practices](https://www.youtube.com/watch?v=vYc6IzKvAJQ)
  shows how to organize the files and make them easier to manage
- [Nixvim: Neovim Distro Powered By Nix](https://www.youtube.com/watch?v=b641h63lqy0):
  configure neovim the nix way!
- [Is NixOS The Best Gaming Distro | Linux Gaming Setup](https://www.youtube.com/watch?v=qlfm3MEbqYA):
  nix can be used for gaming too! This video gives nice tips to configure your system for a specific hardware too

[Ampersand](https://www.youtube.com/watch?v=nLwbNhSxLd4)
has a nice video about configuring a NixOS system
similar to vimjoyer's `Ultimate NixOS Guide | Flakes | Home-Manager`

[A Gentle Introduction to Nix Flakes](https://ebzzry.com/en/flakes/) breaks down a flake setup, what each attribute means, and a small introduction to flake-utils.

[Why you don't need flake-utils](https://ayats.org/blog/no-flake-utils) explains why flake-utils are not really needed and alternative custom nix code (or use flake-parts? but I am a numtide fan :))

### Nix Language

- [explainix](https://zaynetro.com/explainix) let's you hover over parts of an expression
  and find out what the syntax means
- [inherit keyword](https://www.ersocon.net/articles/master-nix-inherit-keyword-in-5-minutes~c464b126-0d57-4971-9a87-2515f9aa8d19)

### High Level Libraries

[flake-utils](https://github.com/numtide/flake-utils)

[flake-parts](https://flake.parts/)

[snowfall](https://snowfall.org/) has many projects, but the most relevant one here is [snowfall lib](https://snowfall.org/guides/lib/quickstart/). This flake repository is trying to use the underlying folder structure of snowfall lib.

## Clean-up

It can get a bit messy with the generations, especially if nix is installed as a package manager.
To clean up such systems, you can use the following commands:

- `nix-collect-garbage`: can be used on all systems and the parameter `--delete-older-than`
  can be specified with a period (for example `"30 days"`).
  This command is mostly an alias of `nix-store --gc` or `nix store gc`,
  but extends it with the `--delete-older-than` and `--delete-old` flag.
- `nh clean all`: clean everything using the `nh` tool.

## TODO

- Integrate [disko](https://github.com/nix-community/disko) for each system,
  so it can be built easier later on.
- Alternative way of managing host types -> colmena host tags could be for fine control!

## Fixes

- Thick black borders in Gnome apps. Using `GSK_RENDERER=gl` to fix it for now.
  [Source](https://gitlab.gnome.org/GNOME/gtk/-/issues/6890#note_2232593)
- Sonarr needs DotNET 6, which has reached EOL.
  Using [permit insecure packages](https://github.com/NixOS/nixpkgs/issues/360592#issuecomment-2513490613)
  we can allow those to be installed. Follow the issue for more information.
  Affected locations:
  - GitHub check action: remove impure when fixed
  - arr module: nixpkgs config is not working tho...
  - Kuchiki needs to be built with `NIXPKGS_ALLOW_INSECURE=1 nh os switch -- --impure`

## Credits

- [use-the-fork](https://github.com/use-the-fork) helped me to [move](https://www.reddit.com/r/NixOS/comments/1eely7a/access_homemanager_config_from_my_nixos_config/) from a standalone config for home-manager to using it as a module
- [u/paulgdp](https://www.reddit.com/user/paulgdp/) gave [advice](https://www.reddit.com/r/NixOS/comments/19c5een/comment/kiwxy8b/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button) on how `nixosConfig` is an attribute of `args` if the config is used in NixOS, used in `modules/home-manager/imports.nix`
- `olmokramer` gave an example on how to use `lib.genAttrs` in a [forum post](https://discourse.nixos.org/t/flakes-how-to-automatically-set-machine-hostname-to-nixosconfiguration-name/45217/2) to configure NixOS systems → extended it for home-manager too
