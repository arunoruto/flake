# New Setup
With a fresh install, delete all the contents under `/etc/nixos/configuration.nix` and include an aditional import for the `config/configuration.nix` file. In the end, it should look like this:
```nix
{ ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./config/configuration.nix
    ];
}
```
Now we need to create a symlink to the contents of this repo to the folder `/etc/nixos/config`. Either execute the `link.sh` file (`./link.sh` or `bash link.sh`) or execute the command:
```sh
sudo ln -s $PWD /etc/nixos/config
```

Now you can sync the contents of this repo with your system config without using `sudo git ...`.

# Install home manager [standalone](https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone)
```sh
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
sudo nix-channel --update
```
After adding the home manager channel, install it and create the first generation with
```sh
nix-shell '<home-manager' -A install
```

# Add unstable for bleeding edge packages
```sh
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs-unstable
sudo nix-channel --update
```
