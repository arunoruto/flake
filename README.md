# Mirza's Awesome Nix Config

<!-- https://www.reddit.com/r/NixOS/comments/16ky6ez/nixos_logo_variations/ -->

![alternative nixos logo](https://preview.redd.it/nixos-logo-variations-v0-yr95r3otvsob1.png?width=1024&format=png&auto=webp&s=d0a14a613101103a31844ab60a711128286468a2)

## Initial setup

### NixOS

When first time trying to install the flake, you need to run:

```sh
sudo nixos-rebuild switch --flake './#<device-name>'
```

### Home Manager

Like NixOS, home-manager can be also updated from the flake file like follows:

```sh
home-manager switch --flake "./#<username>"
```

The flake specifications are surrounded by quotes, since some shells (e.g. zsh) are complaining due to the # symbol.

## Nix Helper

After the initial setup, the system can be configured using the `nh` command. It is important to provide the `FLAKE` variable in the system and it needs to point to the flake's repository. This can be specified per system in its `configuration.nix` under `environment.sessionVariables`. If not, it can be appended to the commands.

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
