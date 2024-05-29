# Mirza's Awesome Nix Config

![https://www.reddit.com/r/NixOS/comments/16ky6ez/nixos_logo_variations/](https://preview.redd.it/nixos-logo-variations-v0-yr95r3otvsob1.png?width=1024&format=png&auto=webp&s=d0a14a613101103a31844ab60a711128286468a2)

## Initial setup

Clone the repository into your local `.config` directory.

```sh
git clone https://github.com/arunoruto/nix ~/.config/nix
```

If it deviates from this, set the env-variable `FLAKE` to the new path.

### NixOS

When first time trying to install the flake, you need to run:

```sh
sudo nixos-rebuild switch --flake "./#<device-name>"
```

### Home Manager

Like NixOS, home-manager can be also updated from the flake file like follows:

```sh
home-manager switch --flake "./#<username>"
```

The flake specifications are surrounded by quotes, since some shells (e.g. zsh) are complaining due to the # symbol.

## Nix Helper

After the initial setup, the system can be configured using the [`nh`](https://github.com/viperML/nh) command. It is important to provide the `FLAKE` variable in the system and it needs to point to the flake's repository. This can be specified per system in its `configuration.nix` under `environment.sessionVariables`. If not, it can be appended to the commands.

### NixOS

```sh
nh os switch # if the FLAKE variable is set, or
nh os switch "./#<device-name>"
```

### Home Manager

```sh
nh home switch # if the FLAKE variable is set, or
nh home switch "./#<username>"
```

## Nixvim

Nixvim is the nix way to configure neovim. More information can be found in the [nvim README](./../home-manager/shell/nvim/README.md).

# Helpful Material

Some nice intro is provided by [thiscute.world](https://nixos-and-flakes.thiscute.world/).

[vimjoyer](https://www.youtube.com/@vimjoyer) has some amazing videos about nix and other nix related stuff:

- [Ultimate NixOS Guide | Flakes | Home-manager](https://www.youtube.com/watch?v=a67Sv4Mbxmc) gives a good introduction for beginners, and introduces flakes and how to use them to configure the system
- [Modularize NixOS and Home Manager | Great Practices](https://www.youtube.com/watch?v=vYc6IzKvAJQ) shows how to organize the files and make them easier to manage
- [Nixvim: Neovim Distro Powered By Nix](https://www.youtube.com/watch?v=b641h63lqy0): configure neovim the nix way!
- [Is NixOS The Best Gaming Distro | Linux Gaming Setup]: nix can be used for gaming too! This video gives nice tips to configure your system for a specific hardware too

[Ampersand](https://www.youtube.com/watch?v=nLwbNhSxLd4) has a nice video about configuring a NixOS system similar to vimjoyer's `Ultimate NixOS Guide | Flakes | Home-Manager`
