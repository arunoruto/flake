{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.programs.localsend.enable {
    programs.localsend = {
      package = pkgs.unstable.localsend;
      openFirewall = true;
    };
  };
}
