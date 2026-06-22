# https://www.gerritcodereview.com/
# https://meldmerge.org/
{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs = {
    jujutsu = {
      enable = config.hosts.development.enable;
      package = pkgs.unstable.jujutsu;
      settings = {
        inherit (config.programs.git.settings.user) name email;
        ui = {
          default-command = [
            "log"
            "--no-pager"
            # "--reversed"
          ];
        };
      };
    };
  };

  home.packages = lib.optionals config.programs.jujutsu.enable (
    with pkgs.unstable;
    [
      # lazyjj
      jjui
    ]
  );
}
