# MPD as the primary user, playing through PipeWire when that runs, whenever
# `services.mpd` is on.
{
  config,
  lib,
  ...
}:
let
  primaryUserName = config.users.primaryUser;
in
{
  config = lib.mkIf config.services.mpd.enable {
    services.mpd = {
      user = primaryUserName;
      # MPD plays nothing without at least one output.
      settings.audio_output = lib.optionals config.services.pipewire.enable [
        {
          type = "pipewire";
          name = "My PipeWire Output";
        }
      ];
    };

    systemd.services.mpd.environment = {
      # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
      XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.${primaryUserName}.uid}"; # User-id must match above us
    };
  };
}
