{
  inputs,
  self,
  lib,
  pkgs-attrs,

  scheme,
  image,
}:
lib.attrsets.mergeAttrsList (
  lib.lists.forEach (lib.lists.remove "iso" (lib.getDirectories ./.)) (
    arch:
    lib.genAttrs (lib.getDirectories ./${arch}) (
      hostname:
      lib.nixosSystem (
        let
          pkgs = import inputs.nixpkgs ({ system = arch; } // pkgs-attrs);
        in
        {
          system = arch;
          specialArgs = {
            inherit inputs self;
          };
          modules = [
            self.nixosModules.default
            # TODO: enable support for multiple users in the future
            # Could be relevant for setting up a kodi or github-runner user
            # username = lib.lists.elemAt conf.usernames 0;
            # username = machines."${hostname}";
            {
              nixpkgs = {
                hostPlatform = arch;
                config = pkgs-attrs.config;
                overlays = pkgs-attrs.overlays ++ [ self.overlays.python ];
              };
            }
            (
              { lib, ... }:
              {
                options.username = lib.mkOption {
                  type = lib.types.str;
                  default = "mirza";
                };
              }
            )
            {
              networking.hostName = lib.mkForce hostname;
              facter.reportPath = lib.mkIf (lib.pathExists ./${arch}/${hostname}/facter.json) ./${arch}/${hostname}/facter.json;
              theming = {
                inherit scheme;
                inherit image;
              };
            }
            ./${arch}/${hostname}
            ../homes/nixos.nix
          ]
          ++ (with inputs; [
            nixos-facter-modules.nixosModules.facter
            home-manager.nixosModules.home-manager
            # lix-module.nixosModules.default
            # determinate.nixosModules.default
            # nur.nixosModules.nur
          ]);
        }
      )
    )
  )
)
