{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.services.docling-serve.enable {
    services.docling-serve = {
      package = pkgs.unstable.docling;
      openFirewall = true;
    };
  };
}
