{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.services.desktopManager.cosmic.enable {
    # nix.settings = {
    #   substituters = [ "https://cosmic.cachix.org/" ];
    #   trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    # };

    services.desktopManager.cosmic = {
      xwayland.enable = true;
      excludePackages = [ ];
    };
  };
}
