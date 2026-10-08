{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.matlab;
in
{
  options.programs.matlab = {
    enable = lib.mkEnableOption "MATLAB, installed from mpm downloads and run in an FHS environment";

    package = lib.mkPackageOption pkgs "matlab" { };

    release = lib.mkOption {
      type = lib.types.str;
      default = "R2025a";
      description = "MATLAB release tag (e.g. R2025a). Changing it needs new hashes.";
    };

    update = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 1;
      description = "Update level of the release; pinned so the download hashes stay stable.";
    };

    hash = lib.mkOption {
      type = lib.types.str;
      default = "sha256-uVhTEovwJsVye7DukMhmUhsDmtuuNEQQy71PBniaEbU=";
      description = "Hash of the MATLAB download for `release` and `update`.";
    };

    products = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        Symbolic_Math_Toolbox = "sha256-154gIbMXDCpph+YdyMCL5aji5QuK1MOw0WPEFgCCohs=";
      };
      description = ''
        Toolboxes to install alongside MATLAB, as product name -> hash of its
        download. Use `lib.fakeHash` for a new one and copy the hash from the error.
      '';
    };

    licenseFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Path to your network.lic file on the host system.";
      example = "/etc/nixos/secrets/network.lic";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (cfg.package.override {
        inherit (cfg)
          release
          update
          hash
          products
          licenseFile
          ;
      })
    ];
  };
}
