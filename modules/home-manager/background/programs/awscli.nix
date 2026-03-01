{
  pkgs,
  lib,
  config,
  ...
}:
{
  # config = lib.mkIf config.programs.awscli.enable {
  config = {
    programs.awscli = {
      settings = {
        default = { };
      };
    };
  };
}
