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
          # Import the default Darwin modules
          self.darwinModules.default
          # Include the host-specific configuration
          ./${arch}/${hostname}
        ]
        ++ (with inputs; [
          stylix.darwinModules.stylix
          home-manager.darwinModules.home-manager
          {
            home-manager.sharedModules = [
              stylix.homeModules.stylix
              (
                {
                  config,
                  osConfig,
                  lib,
                  ...
                }:
                {
                  # Inherit stylix config from system (Darwin) level
                  stylix.enable = true;
                  stylix.image = osConfig.stylix.image;
                  stylix.base16Scheme = osConfig.stylix.base16Scheme;
                  stylix.polarity = osConfig.stylix.polarity;
                }
              )
            ];
          }
          sops-nix.darwinModules.sops
        ]);
      }
    )
  )
)
