{
  inputs,
  self,
  lib,
  pkgs-attrs,

  scheme,
  image,
}:
let
  unique-users = lib.lists.remove "keys" (lib.getDirectories ./.);
  # Standalone home-manager is only used on x86_64-linux machines; on Darwin
  # (and NixOS) home-manager is wired in through the system configuration.
  pkgs = import inputs.nixpkgs ({ system = "x86_64-linux"; } // pkgs-attrs);
in
lib.genAttrs unique-users (
  user:
  inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit inputs pkgs; };
    modules = [
      self.homeModules.default
      { user = lib.mkDefault user; }
      ./${user}
      {
        theming = {
          inherit scheme;
          inherit image;
        };
      }
    ]
    ++ (with inputs; [
      # stylix.homeManagerModules.stylix
      stylix.homeModules.stylix
    ]);
  }
)
