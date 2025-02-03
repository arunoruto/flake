{
  inputs,
  lib,
  config,
  ...
}:
let
  available = inputs ? "nixos-cosmic";
in
{
  imports = lib.optionals available [
    inputs.nixos-cosmic.nixosModules.default
  ];

  options.cosmic.enable = lib.mkEnableOption "Enable System76 DE: Cosmic (Alpha)";

  config = lib.mkIf (available && config.cosmic.enable) {
    nix.settings = {
      substituters = [ "https://cosmic.cachix.org/" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    };

    services.desktopManager = lib.optionalAttrs (config.services.desktopManager ? "cosmic") {
      cosmic.enable = true;
    };
  };
}
