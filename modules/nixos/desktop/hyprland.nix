{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.programs.hyprland.enable {
    programs.hyprland = {
      xwayland.enable = true;

      # uwsm wraps the compositor in real systemd units (graphical-session
      # target, XDG autostart, ordered shutdown) and registers its own
      # "Hyprland (uwsm-managed)" session entry. home-manager's competing
      # hyprland-session.target is switched off to match -- see
      # modules/home-manager/foreground/desktop/hyprland/default.nix.
      withUWSM = lib.mkDefault true;
    };

    # hyprlock authenticates through PAM. Without a stack of its own it falls
    # back to `su` and cannot unlock the session at all; the NixOS hyprlock
    # module is not used here because home-manager owns the hyprlock config.
    # (fprintAuth defaults to services.fprintd.enable, so a host with a
    # fingerprint reader picks that up on its own.)
    security.pam.services.hyprlock = { };

    # Brightness and volume function keys on laptops.
    hardware.acpilight.enable = lib.mkDefault true;
  };
}
