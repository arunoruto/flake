{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./fingerprint.nix
    ./rssh.nix
    ./secrets.nix
    ./tpm
    ./yubikey
  ];

  secrets.enable = lib.mkDefault true;
  security = {
    yubikey = {
      enable = lib.mkOptionDefault false;
      identifiers = { };
    };

    polkit.enable = true;
    sudo.package =
      if (config.lib.tags.hasTag "desktop") then
        pkgs.sudo.override { withInsults = true; }
      else
        pkgs.sudo;
  };

  # environment.systemPackages = with pkgs; [
  #   clevis
  # ];
}
