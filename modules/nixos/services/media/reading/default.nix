{ lib, config, ... }:
{
  imports = [
    ./komga.nix
    ./stump.nix
    ./manga.nix
    ./paperless.nix
  ];

  assertions = [
    {
      assertion = !(config.services.komga.enable && config.services.stump.enable);
      message = "Cannot enable both komga and stump — they share library.${config.services.cloudflared.defaultDomain}";
    }
  ];
}
