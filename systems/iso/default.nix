{
  inputs,
  self,
  lib,
}:
let
  # Hosts that get a bootable installer image. Single source of truth for both
  # nixosConfigurations.iso-<host> and packages.x86_64-linux.iso-<host>.
  hosts = [
    "shinji"
    "kenpachi"
  ];

  mkIso =
    hostname:
    lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs self hostname; };
      modules = [ ./installer.nix ];
    };
in
{
  isoConfigurations = lib.listToAttrs (
    map (hostname: lib.nameValuePair "iso-${hostname}" (mkIso hostname)) hosts
  );
}
