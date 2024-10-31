{
  config,
  lib,
  pkgs,
  ...
}:
let
  localsendPort = 53317;
in
{
  options.localsend.enable = lib.mkEnableOption "Enable localsend for local network file sharing";

  config = lib.mkIf config.localsend.enable {
    environment.systemPackages = with pkgs; [
      unstable.localsend
    ];

    networking = {
      firewall = {
        allowedTCPPorts = [ localsendPort ];
        allowedUDPPorts = [ localsendPort ];
      };
    };
  };
}
