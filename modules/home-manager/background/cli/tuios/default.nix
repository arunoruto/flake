{
  config,
  lib,
  ...
}:
{
  imports = [
    ./module.nix
  ];

  config = lib.mkIf config.programs.tuios.enable {
    programs.tuios = {
      settings = {
        appearance = {
          preferred_shell = config.shell.main;
          # tmux: status-position top
          dockbar_position = "top";
          # tmux status-right: cpu | ram | clock
          show_clock = true;
          show_cpu = true;
          show_ram = true;
        };

        # Everything else in tuios' prefix mode already matches tmux
        # (c/n/p/x/d/z/,/[/0-9), so only the prefix itself needs to move.
        # tmux: shortcut = "Space" -> C-Space prefix
        keybindings.leader_key = "ctrl+space";
      };
    };
  };
}
