{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Disk tooling for `nas`-tagged hosts.
  config = lib.mkIf (config.lib.tags.hasTag "nas") {
    environment.systemPackages = with pkgs; [
      dool
      fatrace
      hdparm
      smartmontools
    ];
    programs.iotop = {
      enable = true;
      package = pkgs.iotop-c;
    };
  };
}
