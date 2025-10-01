pkgs: {
  home-assistant-custom-components = {
    hass-ingress = pkgs.callPackage ./hass-ingress/package.nix { };
  };
}
