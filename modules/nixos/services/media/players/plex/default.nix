{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./tautulli.nix ];

  config = lib.mkIf config.services.plex.enable {
    services.plex =
      let
        cfg = config.services.media;
      in
      {
        package = lib.mkDefault pkgs.unstable.plex;
        dataDir = lib.mkDefault "${cfg.dataDir}/plex";
        openFirewall = lib.mkDefault cfg.openFirewall;
      };

    users.users.plex.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];

    # Nothing here configures VAAPI on purpose. Plex ships its own AMD driver
    # and downloads it under `Plex Media Server/Drivers/rsv-*`, symlinked into
    # `Cache/va-dri-linux-x86_64`, which it then points the transcoder at by
    # setting LIBVA_DRIVERS_PATH itself. That driver is built for plex's musl
    # runtime and exports __vaDriverInit_1_22, matching the libva plex bundles
    # -- so it needs none of the glibc symbols its libgcompat is missing, and
    # none of the version forwarding that mesa's driver does.
    #
    # Handing plex mesa's driver instead actively breaks it: two mesa builds in
    # one process interpose on each other and radeonsi comes up on the virtio
    # path, failing with "vdrm_device_connect failed" and "amdvgpu_device_
    # initialize failed". Measured with plex's own driver and a stock
    # environment, vcn_busy_percent goes 0% -> 92% on a 1080p transcode.
    #
    # So if hardware transcoding is not working, look first at whether plex has
    # fetched its driver (the Drivers directory above) rather than reaching for
    # the host's. Bridging mesa's driver into plex's runtime is possible -- it
    # needs a preloaded shim for the glibc symbols libgcompat lacks, the real
    # driver preloaded again to satisfy its initial-exec TLS, and a stand-in
    # driver to forward libva's versioned entry point -- and it is still the
    # wrong answer, because it buys encode-only where plex's own driver does
    # zero-copy decode and encode both.
  };
}
