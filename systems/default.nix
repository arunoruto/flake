{
  inputs,
  self,
  lib,
  pkgs-attrs,

  scheme,
  image,
}:
let
  machines = {
    # Personal
    isshin.usernames = [ "mirza" ]; # Framework Laptop AMD 7040
    zangetsu.usernames = [ "mirza" ]; # Framework Case Intel 11th
    yhwach.usernames = [ "mirza" ]; # Tower PC
    kuchiki.usernames = [ "mirza" ]; # New NAS Server
    sado.usernames = [ "mirza" ]; # NVMe NAS Server
    lil-nas-x.usernames = [ "mirza" ]; # New NAS Server
    yoruichi.usernames = [ "mirza" ]; # Crappy AMD Mini PC
    shinji.usernames = [ "mirza" ]; # M720q Mini PC
    kenpachi.usernames = [ "mirza" ]; # S740 Mini PC
    # narouter.usernames = [ "mirza" ];# Firewall
    aizen.usernames = [ "mirza" ]; # Server

    # Work
    kyuubi.usernames = [ "mar" ]; # Crappy Work PC
    madara.usernames = [ "mar" ]; # Nice Work PC
  };
in
lib.attrsets.mergeAttrsList (
  lib.lists.forEach (lib.lists.remove "iso" (lib.getDirectories ./.)) (
    arch:
    lib.genAttrs (lib.getDirectories ./${arch}) (
      hostname:
      lib.nixosSystem (
        let
          conf = machines.${hostname};
          pkgs = import inputs.nixpkgs ({ system = arch; } // pkgs-attrs);
        in
        {
          # inherit system;
          system = arch;
          specialArgs = {
            inherit inputs;
            flake = self;
          };
          modules = [
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
                  default = "mirza";
                  # default = lib.lists.elemAt conf.usernames 0;
                };
              }
            )
            {
              networking.hostName = lib.mkForce hostname;
              facter.reportPath = lib.mkIf (lib.pathExists ./${arch}/${hostname}/facter.json) ./${arch}/${hostname}/facter.json;
              nixpkgs.pkgs = pkgs.extend self.overlays.python;
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
