{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./module.nix
    ./theme.nix
  ];

  config = {
    programs.herdr = lib.mkIf config.programs.herdr.enable {
      package = pkgs.unstable.herdr;

      settings = {
        onboarding = false;

        terminal.default_shell = config.shell.main;

        update.version_check = false;

        ui = {
          mouse_capture = true;
          pane_borders = true;
          pane_gaps = true;
          confirm_close = true;
          sidebar_width = 32;
          sound.enabled = false;
        };

        keys = {
          prefix = "ctrl+space";
          zoom = [
            "prefix+z"
            "prefix+m"
          ];
          toggle_sidebar = "prefix+b";
          detach = "prefix+d";
          resize = "prefix+r";
          command = [
            {
              key = "prefix+shift+r";
              type = "shell";
              command = "herdr server reload-config";
              description = "reload herdr config";
            }
          ];
        };

        session.resume_agents_on_restore = true;
      };

      enableZshIntegration = true;
      enableFishIntegration = lib.mkDefault config.programs.fish.enable;
    };
  };
}
