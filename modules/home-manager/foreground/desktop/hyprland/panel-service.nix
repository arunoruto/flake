{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.services.hyprpanel = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable hyprpanel.
      '';
    };

    package = lib.mkPackageOption pkgs "hyprpanel" { };
  };

  config =
    let
      cfg = config.services.hyprpanel;
    in
    lib.mkIf cfg.enable {
      home.packages = [ cfg.package ];
      xdg.configFile."ags".source = pkgs.fetchFromGitHub {
        owner = "Jas-SinghFSU";
        repo = "HyprPanel";
        rev = "a7855baf13c6abdd0b0e988e4390112cd7deda67";
        hash = "sha256-N0unlLf/7BqkrYx3BO9svv1+oLzKpArgiqLzkmNpD3Q=";
      };
    };
}
