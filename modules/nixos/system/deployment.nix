{
  inputs,
  lib,
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
          # name = config.networking.hostName;
          name = null;
          inherit lib;
        }
      ))
      deployment
      ;
  };

  config.colmena.deployment.buildOnTarget = lib.mkDefault true;
}
