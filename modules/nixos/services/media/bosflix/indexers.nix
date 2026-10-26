{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.bosflix;
in
{
  config = lib.mkIf cfg.enable {
    services = {
      # Reachable publicly at arr.<domain>/prowlarr via aizen's tunnel, which
      # is why the urlbase below matters — it is already set in prowlarr's own
      # database, hence the block staying commented rather than fighting it.
      prowlarr = {
        enable = true;
        # package = pkgs.unstable.prowlarr;
        # settings = {
        #   server = {
        #     urlbase = "/prowlarr";
        #     AuthenticationMethod = "Forms";
        #     AuthenticationRequired = "DisabledForLocalAddresses";
        #   };
        # };
      };

      # Solves the Cloudflare interstitials some indexers sit behind; prowlarr
      # talks to it over localhost.
      flaresolverr = {
        enable = true;
        # package = pkgs.nur.repos.xddxdd.flaresolverr-21hsmw;
        # package = pkgs.unstable.flaresolverr;
        package = pkgs.flaresolverr;
      };
    };
  };
}
