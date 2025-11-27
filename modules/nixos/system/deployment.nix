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

  options.colmena = {
    inherit
      (lib.attrsets.getAttrFromPath [ "options" ] (
        inputs.colmena.nixosModules.deploymentOptions {
          name = config.networking.hostName;
          # name = null;
          inherit lib;
        }
      ))
      deployment
      ;
  };

  config = {
    environment.systemPackages = lib.optionals (!(lib.elem "tinypc" config.system.tags)) (
      with pkgs;
      [
        inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena
        deploy-rs
      ]
    );

    colmena.deployment.buildOnTarget = lib.mkDefault true;
  };
}
