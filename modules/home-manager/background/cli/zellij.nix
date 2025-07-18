{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.programs.zellij.enable {
    programs.zellij = {
      package = pkgs.unstable.zellij;
      settings = {
      };
    };
  };
}
