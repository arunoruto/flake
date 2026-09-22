{ config, ... }:
{
  home.sessionVariables =
    let
      EDITOR = config.home.sessionVariables.EDITOR;
    in
    {
      GET_EDITOR = EDITOR;
      VISUAL = EDITOR;
      BROWSER = "zen";
      WINIT_UNIX_BACKEND = "x11";
      # FLAKE = "/home/${user}/.config/flake";
      PATH = "$HOME/.local/bin:$PATH";
    };
}
