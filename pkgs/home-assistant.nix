pkgs: {
  # home-assistant-custom-components = pkgs.lib.recurseIntoAttrs {
  #   hass-ingress = pkgs.callPackage ./hass-ingress/package.nix { };
  # };
  hass-ingress = pkgs.callPackage ./hass-ingress/package.nix { };
}
