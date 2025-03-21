{
  config,
  lib,
  ...
}:
let
  user = config.user;
in
{
  options.environment.enable = lib.mkEnableOption "Set env vars for user";

  config = lib.mkIf config.environment.enable {
    home.sessionVariables = rec {
      # EDITOR = "nvim";
      EDITOR = "hx";
      GET_EDITOR = EDITOR;
      VISUAL = EDITOR;
      BROWSER = "zen";
      WINIT_UNIX_BACKEND = "x11";
      # FLAKE = "/home/${user}/.config/flake";
      PATH = "$HOME/.local/bin:$PATH";
    };
  };
}
