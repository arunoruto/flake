{
  inputs,
  self,
  lib,
  pkgs-attrs,

  scheme,
  image,
}:
let
  unique-users = lib.lists.remove "keys" (lib.systemConfig.listDirs ./.);
  pkgs = import inputs.nixpkgs ({ system = "x86_64-linux"; } // pkgs-attrs);
in
lib.genAttrs unique-users (
  user:
  inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit inputs; };
    modules = [
      # inputs.nur.hmModules.nur
      # ./modules/home-manager/home.nix
      self.homeModules.default
      (
        { lib, ... }:
        {
          options.user = lib.mkOption {
            type = lib.types.str;
            default = user;
          };
        }
      )
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
