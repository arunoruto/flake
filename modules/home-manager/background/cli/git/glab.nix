{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.gitlab;
in
{
  meta.maintainers = with lib.maintainers; [ arunoruto ];

  options.programs.gitlab = {
    enable = lib.mkEnableOption "GitLab CLI tool";

    package = lib.mkPackageOption pkgs "glab" { };

    gitCredentialHelper = {
      enable = lib.mkEnableOption "the glab git credential helper" // {
        default = true;
      };

      hosts = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ "https://gitlab.com" ];
        description = "GitLab hosts to enable the glab git credential helper for.";
        example = [
          "https://gitlab.com"
          "https://gitlab.example.com"
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
            helper = [
              ""
              "${cfg.package}/bin/glab auth git-credential"
            ];
          }
        ) cfg.gitCredentialHelper.hosts
      )
    );
  };
}
