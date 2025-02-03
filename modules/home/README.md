# Install on non NixOS system

Follow the steps on the [official nix](https://nixos.org/download/) website. Multi-user is preferred!

Afterward, home-manager needs to be installed. But before that, some directory changes have to be done (for now it only applies for ubuntu, not debian):

```sh
sudo chown $USER:nixbld /nix/var/nix/{profiles,gcroots}/per-user/$USER
```

Add the home-manager channel (this is the unstable version, for the stable version change `master.tar.gz` to `release-<version, like 23.11>.tar.gz`):

```sh
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
```

Now home-manager can be installed using the following command:

```sh
nix-shell '<home-manager>' -A install
```

Further information can be found at the [home-manager installation docs](https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone).

# NixVim

To configure (neo)vim, I am using [nixvim](https://nix-community.github.io/nixvim/) to manage the instance and the plugins.
Further information are found in the respective [folder](programs/nvim/README.md).

# home-manager in repl

To acces the home-manager config in nix repl, we need to execute the following in the repl:

```nix
hm = import <home-manager/modules> { configuration = ~/.config/home-manager/home.nix; pkgs = import <nixpkgs> {}; }
```
