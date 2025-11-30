{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.services.komga.enable {
    services.komga = {
    };
  };
}
