{
  config,
  lib,
  ...
}:
let
  inherit (config) user;
in
{
  options.environment.enable = lib.mkEnableOption "Set env vars for user";

  config = lib.mkIf config.environment.enable {
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
  };
}
