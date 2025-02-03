{
  config,
  lib,
  inputs,
  ...
}:
{
  options.upgrades.enable = lib.mkEnableOption "Automated upgrades of the flake-based system";

  config = lib.mkIf config.upgrades.enable {
    system.autoUpgrade = {
      enable = true;
      dates = "04:00";
      randomizedDelaySec = "15min";
      flake = inputs.self.outPath;
      flags = [
        "--update-input"
        "nixpkgs"
        "-L"
      ];
    };
  };
}
