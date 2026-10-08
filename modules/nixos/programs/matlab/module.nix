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
    enable = lib.mkEnableOption "MATLAB in an FHS environment, installed per user with mpm";

    package = lib.mkPackageOption pkgs "matlab" { };

    release = lib.mkOption {
      type = lib.types.str;
      default = "R2025a";
      description = "MATLAB release tag (e.g. R2025a); each release gets its own folder.";
    };

    products = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "Symbolic_Math_Toolbox" ];
      description = ''
        Products `matlab-sync` makes sure are installed, besides MATLAB itself.
        Anything beyond this list can still be installed from within MATLAB.
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
        inherit (cfg) release products licenseFile;
      })
    ];
  };
}
