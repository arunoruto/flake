{ inputs, lib, ... }:
let
  available = inputs ? "nix-flatpak";
in
{
  imports = lib.optionals available [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  config = lib.mkIf available {
    services.flatpak.packages = [
      "us.zoom.Zoom"
    ];
  };
}
