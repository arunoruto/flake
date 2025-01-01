{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./ghostty-module.nix
    ./hm.nix
  ];

  config = {
    programs.ghostty = {
      # package = inputs.ghostty.packages.x86_64-linux.default;
      package = pkgs.unstable.ghostty;

      settings = {
        # background-blur-radius = 20;
        window-height = config.terminals.height;
        window-width = config.terminals.width;
        keybind = [
          "alt+enter=toggle_fullscreen"
          "alt+h=previous_tab"
          "alt+l=next_tab"
        ];
      };
    };
  };
}
