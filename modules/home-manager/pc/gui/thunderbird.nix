{pkgs, ...}: {
  programs.thunderbird = {
    enable = true;
    package = pkgs.unstable.thunderbird-128;
    profiles.mirza = {
      isDefault = true;
    };
  };
}
