{
  description = "Mirzas Nix Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations.zangetsu = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./nisox/hosts/zangetsu/configuration.nix
      ];
    };
  };
}
