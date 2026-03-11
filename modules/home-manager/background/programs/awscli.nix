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
        work = {
          region = "garage";
          endpoint_url = "https://s3.bv.e-technik.tu-dortmund.de";
        };
      };
    };
  };
}
