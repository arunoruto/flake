{
  inputs,
  self,
  lib,
  pkgs-attrs,

  scheme,
  image,
}:
lib.attrsets.mergeAttrsList (
  lib.lists.forEach (lib.getDirectories ./.) (
    arch:
    lib.genAttrs (lib.getDirectories ./${arch}) (
      hostname:
      inputs.nix-darwin.lib.darwinSystem {
        system = arch;
        specialArgs = {
          inherit inputs self;
        };
        modules = [
          # Include the host-specific configuration
          ./${arch}/${hostname}
        ]
        ++ (with inputs; [
          home-manager.darwinModules.home-manager
          stylix.darwinModules.stylix
          sops-nix.darwinModules.sops
          nix-homebrew.darwinModules.nix-homebrew
        ]);
      }
    )
  )
)
