{
  config,
  lib,
  username,
  ...
}: {
  options = {
    mpd.enable = lib.mkEnableOption "Enable mpd";
  };

  config = lib.mkIf config.mpd.enable {
    services.mpd = {
      enable = false;
      #musicDirectory = "/path/to/music";
      user = username;
      extraConfig =
        ''
          # must specify one or more outputs in order to play audio!
          # (e.g. ALSA, PulseAudio, PipeWire), see next sections
        ''
        + lib.optionalString (config.services.pipewire.enable) ''
          audio_output {
            type "pipewire"
            name "My PipeWire Output"
          }
        '';

      # Optional:
      # network.listenAddress = "any"; # if you want to allow non-localhost connections
      # network.startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
    };

    systemd.services.mpd.environment = {
      # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
      XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.${username}.uid}"; # User-id must match above user. MPD will look inside this directory for the PipeWire socket.
    };
  };
}
