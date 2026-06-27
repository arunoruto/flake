{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./module.nix ];

  config = {
    programs.herdr = lib.mkIf config.programs.herdr.enable {
      package = pkgs.custom.herdr;

      settings = {
        theme.name = "catppuccin";

        ui = {
          mouse_capture = true;
          pane_borders = true;
          pane_gaps = true;
          confirm_close = true;
          sidebar_width = 32;
        };

        keys = {
          prefix = "ctrl+b";
          zoom = "prefix+z";
          toggle_sidebar = "prefix+b";
          detach = "prefix+q";
        };

        session.resume_agents_on_restore = true;
      };

      enableZshIntegration = true;
      enableFishIntegration = lib.mkDefault config.programs.fish.enable;
    };
  };
}
