{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.hosts.desktop.enable {
    home.packages = [ pkgs.tdf ];
  };
}
