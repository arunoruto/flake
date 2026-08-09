{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    shell.main = "fish";
    programs = lib.optionalAttrs config.hosts.desktop.enable {
      fish.enable = true;
      # nushell.enable = true;
      zsh.enable = pkgs.stdenv.hostPlatform.isDarwin;
    };

    # `command` follows `package`, so pointing at the unstable build is enough.
    # Keeps devix's nixfmt aligned with the unstable one in nix-utils.nix,
    # avoiding a home-manager-path buildEnv conflict between the two 1.4.0 builds.
    devix.formatters.nixfmt.package = pkgs.unstable.nixfmt;
  };
}
