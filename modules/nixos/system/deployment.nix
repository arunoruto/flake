{
  inputs,
  lib,
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
    # colmena/deploy-rs binaries live on `management`-tagged hosts (see
    # ./tags/management.nix); this module only wires the deployment options.
    colmena.deployment.buildOnTarget = lib.mkDefault true;
  };
}
