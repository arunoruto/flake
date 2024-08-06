{
  config,
  lib,
  user,
  ...
}: {
  options = {
    environment.enable = lib.mkEnableOption "Set env vars for user";
  };

  config = lib.mkIf config.environment.enable {
    # You can also manage environment variables but you will have to manually
    # source
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/mar/etc/profile.d/hm-session-vars.sh
    #
    # if you don't want to manage your shell through Home Manager.
    home.sessionVariables = {
      # EDITOR = "nvim";
      EDITOR = "hx";
      BROWSER = "firefox";
      WINIT_UNIX_BACKEND = "x11";
      FLAKE = "/home/${config.users.users}/.config/flake";
    };
  };
}
