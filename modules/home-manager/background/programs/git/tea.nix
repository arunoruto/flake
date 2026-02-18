{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.tea;
in
{
  meta.maintainers = with lib.maintainers; [ arunoruto ];

  options.programs.tea = {
    enable = lib.mkEnableOption "Gitea CLI tool";

    package = lib.mkPackageOption pkgs "tea" { };

    gitCredentialHelper = {
      enable = lib.mkEnableOption "the tea git credential helper" // {
        default = true;
      };

      hosts = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ "https://gitea.com" ];
        description = "Gitea hosts to enable the tea git credential helper for.";
        example = [
          "https://gitea.com"
          "https://git.yourdomain.com"
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.git.settings.credential = lib.mkIf cfg.gitCredentialHelper.enable (
      builtins.listToAttrs (
        map (
          host:
          lib.nameValuePair host {
            # The empty string "" clears any previously configured helpers for this host
            # before applying the tea credential helper.
            # The '!' tells Git to run this as a shell command.
            helper = [
              ""
              "!${lib.getExe cfg.package} login helper"
            ];
          }
        ) cfg.gitCredentialHelper.hosts
      )
    );
  };
}
