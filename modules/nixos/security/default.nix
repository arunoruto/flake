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

  rssh.enable = lib.mkDefault (!config.yubikey.enable && config.services.openssh.enable);
  secrets.enable = lib.mkDefault true;
  tpm.enable = lib.mkOptionDefault false;
  yubikey = {
    enable = lib.mkOptionDefault false;
    identifiers = { };
  };

  security = {
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
