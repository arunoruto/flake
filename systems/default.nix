{
  inputs,
  self,
  lib,
  pkgs-attrs,

  scheme,
  image,
}:
let
  # Filter out Darwin architectures and iso
  isLinuxArch = arch: !(lib.hasInfix "darwin" arch);
  linuxArchs = lib.filter isLinuxArch (lib.lists.remove "iso" (lib.getDirectories ./.));
in
lib.attrsets.mergeAttrsList (
  lib.lists.forEach linuxArchs (
    arch:
    lib.genAttrs (lib.getDirectories ./${arch}) (
      hostname:
      let
        pkgs = import inputs.nixpkgs {
          system = arch;
          inherit (pkgs-attrs) config;
          overlays = pkgs-attrs.overlays ++ [ self.overlays.python ];
        };
      in
      lib.nixosSystem {
        inherit pkgs;
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
          determinate.nixosModules.default
          # lix-module.nixosModules.default
          # nur.nixosModules.nur
        ]);
      }
    )
  )
)
