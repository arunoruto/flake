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
          self.darwinModules.default
          {
            networking.hostName = hostname;
            home-manager.sharedModules = [
              inputs.stylix.homeModules.stylix
              (
                { osConfig, ... }:
                {
                  # Inherit stylix config from system (Darwin) level
                  stylix.enable = true;
                  stylix.image = osConfig.stylix.image;
                  stylix.base16Scheme = osConfig.stylix.base16Scheme;
                  stylix.polarity = osConfig.stylix.polarity;
                }
              )
              inputs.mac-app-util.homeManagerModules.default

            ];
          }
          ./${arch}/${hostname}
        ]
        ++ (with inputs; [
          stylix.darwinModules.stylix
          home-manager.darwinModules.home-manager
          sops-nix.darwinModules.sops
          determinate.darwinModules.default
          mac-app-util.darwinModules.default
        ]);
      }
    )
  )
)
