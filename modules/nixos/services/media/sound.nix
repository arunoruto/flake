{
  config,
  lib,
  ...
}:
{
  options = {
    pipewire.enable = lib.mkEnableOption "Enable pipewire";
  };
  config = lib.mkIf config.pipewire.enable {
    # Enable sound with pipewire.
    # sound.enable = lib.mkForce false;
    services.pulseaudio.enable = false;
    # rtkit is optional but recommended
    security.rtkit.enable = true;

    # Helpful config: https://nixos.wiki/wiki/PipeWire
    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;
    };
  };
}
