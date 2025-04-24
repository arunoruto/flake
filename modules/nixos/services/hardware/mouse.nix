{
  pkgs,
  lib,
  config,
  ...
}:
let
  devices = pkgs.copyPathToStore ./libratbag-devices;
in
{
  options.hardware.mouse.enable = lib.mkEnableOption "Enable mouse config";

  config = lib.mkIf config.hardware.mouse.enable {
    services.ratbagd = {
      enable = true;
      package = pkgs.libratbag.overrideAttrs (old: {
        postInstall =
          (old.postInstall or "")
          + ''
            install -Dm444 ${devices}/* $out/share/libratbag
          '';
      });
    };
    environment.systemPackages = [ pkgs.piper ];
  };
}
