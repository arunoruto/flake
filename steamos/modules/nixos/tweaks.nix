# SteamOS' opinionated system tuning, minus everything specific to Valve's
# hardware. Each setting is a `mkDefault` so a consumer can override one
# without turning the group off.
{
  config,
  lib,
  ...
}:
let
  cfg = config.steamos;
in
{
  config = lib.mkIf (cfg.enable && cfg.tweaks.enable) {
    boot.kernel.sysctl = {
      # Some storefronts and matchmaking services sit behind PMTU black holes;
      # SteamOS probes rather than stalling.
      # https://github.com/ValveSoftware/SteamOS/issues/1006
      "net.ipv4.tcp_mtu_probing" = lib.mkDefault 1;

      # A game killed and restarted quickly cannot rebind its port while the
      # old socket lingers, and the default timeout is far longer than a
      # relaunch takes.
      "net.ipv4.tcp_fin_timeout" = lib.mkDefault 5;
    };

    # A console has no swap partition to fall back on, and shaders, Proton and
    # a browser-based UI make a machine that is happy to use all of it.
    zramSwap = {
      enable = lib.mkDefault true;
      algorithm = lib.mkDefault "zstd";
      memoryPercent = lib.mkDefault 50;
      priority = lib.mkDefault 100;
    };

    # Under memory pressure the kernel's own OOM killer arrives long after the
    # machine has stopped responding, which on a controller-driven box means a
    # hard reset. Thresholds match SteamOS' holo-earlyoom config.
    services.earlyoom = {
      enable = lib.mkDefault true;
      freeMemThreshold = lib.mkDefault 5;
      freeSwapThreshold = lib.mkDefault 5;
    };
  };
}
