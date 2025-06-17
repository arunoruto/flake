{
  inputs,
  self,
  lib,
  system,

  scheme,
  image,
}:
let
  machines = {
    # Personal
    # Framework Laptop AMD 7040
    isshin.usernames = [ "mirza" ];
    # Framework Case Intel 11th
    zangetsu.usernames = [ "mirza" ];
    # Tower PC
    yhwach.usernames = [ "mirza" ];
    # New NAS Server
    kuchiki.usernames = [ "mirza" ];
    # Crappy AMD Mini PC
    yoruichi.usernames = [ "mirza" ];
    # M720q Mini PC
    shinji.usernames = [ "mirza" ];
    # S740 Mini PC
    kenpachi.usernames = [ "mirza" ];
    # Firewall
    # narouter.usernames = [ "mirza" ];
    # Server
    aizen.usernames = [ "mirza" ];

    # Work
    # Crappy Work PC
    kyuubi.usernames = [ "mar" ];
    # Nice Work PC
    madara.usernames = [ "mar" ];
  };

in
builtins.mapAttrs (
  hostname: conf:
  lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs;
      flake = self;
    };
    modules =
      [
        self.nixosModules.default
        # TODO: enable support for multiple users in the future
        # Could be relevant for setting up a kodi or github-runner user
        # username = lib.lists.elemAt conf.usernames 0;
        # username = machines."${hostname}";
        (
          { lib, ... }:
          {
            options.username = lib.mkOption {
              type = lib.types.str;
              default = lib.lists.elemAt conf.usernames 0;
            };
          }
        )
        {
          networking.hostName = lib.mkForce hostname;
          facter.reportPath = lib.mkIf (lib.pathExists ./${hostname}/facter.json) ./${hostname}/facter.json;
          nixpkgs = {
            config.allowUnfree = true;
            overlays =
              (with self.overlays; [
                additions
                python
                unstable-packages
              ])
              ++ (with inputs; [
                nur.overlays.default
              ]);
          };
          theming = {
            inherit scheme;
            inherit image;
          };
        }
        ./${hostname}
        ../homes/nixos.nix
      ]
      ++ (with inputs; [
        nixos-facter-modules.nixosModules.facter
        home-manager.nixosModules.home-manager
        nixai.nixosModules.default
        # lix-module.nixosModules.default
        # determinate.nixosModules.default
        # nur.nixosModules.nur
      ]);
  }
) machines
