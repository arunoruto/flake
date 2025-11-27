{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./headless.nix
    ./laptop.nix
    ./tinypc.nix
    ./workstation.nix
  ];

  options.system.tags = lib.mkOption {
    # type = lib.types.listOf lib.types.str;
    type = with lib.types; listOf str;
    default = [ ];
    description = ''
      List of tags for this system. This can be used to identify
      this system in scripts or other tools.
    '';
  };

  config = {
  }
  // lib.optionalAttrs (inputs ? colmena) {
    colmena.deployment.tags = config.system.tags;
    environment.systemPackages = [ inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena ];
  };
}
