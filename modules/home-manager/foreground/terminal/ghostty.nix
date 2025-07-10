{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}@args:
{
  programs.ghostty = {
    # package = pkgs.unstable.ghostty;
    package =
      if
        (
          (args ? nixosConfig)
          && (builtins.elem osConfig.boot.kernelPackages.kernel.version (
            lib.lists.forEach [ "4" "5" ] (x: "6.15." + x)
          ))
        )
      then
        (pkgs.unstable.ghostty.overrideAttrs (_: {
          preBuild = ''
            shopt -s globstar
            sed -i 's/^const xev = @import("xev");$/const xev = @import("xev").Epoll;/' **/*.zig
            shopt -u globstar
          '';
        }))
      else
        pkgs.unstable.ghostty;

    enableBashIntegration = lib.mkDefault true;
    enableFishIntegration = lib.mkDefault true;
    enableZshIntegration = lib.mkDefault true;

    settings = {
      # background-blur-radius = 20;
      background-blur = 20;
      window-height = config.terminals.height;
      window-width = config.terminals.width;
      keybind = [
        "alt+enter=toggle_fullscreen"
        "alt+h=previous_tab"
        "alt+l=next_tab"
      ];
    };
  };
}
