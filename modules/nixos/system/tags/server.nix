{
  lib,
  config,
  ...
}:
{
  # Headless infrastructure boxes. This tag is what modules should gate
  # server *roles* on (tailscale advertising, no sound stack, ...) — never
  # the absence of an interactive tag like `desktop`: a workstation or
  # laptop without `desktop` is still somebody's machine, not a server.
  config = lib.mkIf (config.lib.tags.hasTag "server") {
    services.pipewire.enable = lib.mkDefault false;
  };
}
