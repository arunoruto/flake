{
  inputs,
  config,
  pkgs,
  lib,
  username,
  theme,
  image,
  ...
}:
{
  sops.secrets."passwords/${username}".neededForUsers = true;

  users = {
    # mutableUsers = false;
    users.${username} = {
      isNormalUser = true;
      # hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
      # shell = pkgs.${config.home-manager.users.${username}.shell};
      shell =
        config.home-manager.users.${username}.programs.${
          config.home-manager.users.${username}.shell
        }.package;
      description = "Mirza";
      extraGroups = [
        "dialout"
        "networkmanager"
        "wheel"
        "scanner"
        "lp"
        "pipewire"
        "audio"
        "video"
        "render"
        "input"
        "uinput"
        "tss" # tss group has access to TPM devices
      ];
    };
  };

  programs.zsh.enable = true;

  environment.sessionVariables.FLAKE = "/home/${username}/.config/flake";
}
