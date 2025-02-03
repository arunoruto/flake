{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  # imports = [
  #   (inputs.colmena.nixosModules.deploymentOptions {
  #     # name = config.networking.hostName;
  #     name = null;
  #     inherit lib;
  #   })
  # ];

  # options.colmena = {
  #   inherit
  #     (lib.attrsets.getAttrFromPath [ "options" ] (
  #       inputs.colmena.nixosModules.deploymentOptions {
  #         name = config.networking.hostName;
  #         # name = null;
  #         inherit lib;
  #       }
  #     ))
  #     deployment
  #     ;
  # };

  # config = lib.mkIf (inputs ? "colmena") {
  #   environment.systemPackages = lib.optionals (!config.hosts.tinypc.enable) (
  #     with pkgs;
  #     [
  #       inputs.colmena.packages.${pkgs.system}.colmena
  #       deploy-rs
  #     ]
  #   );

  #   colmena.deployment.buildOnTarget = lib.mkDefault true;
  # };
}
