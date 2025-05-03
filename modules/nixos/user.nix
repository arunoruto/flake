{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  username = config.username;
  shell = config.home-manager.users.${username}.shell.main;
in
{
  sops.secrets."passwords/${username}".neededForUsers = true;

  users = {
    # mutableUsers = false;
    users.${username} = {
      isNormalUser = true;
      # hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
      # shell = pkgs.${config.home-manager.users.${username}.shell};
      shell = config.home-manager.users.${username}.programs.${shell}.package;
      description = "Mirza";
      extraGroups =
        [
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
        ]
        ++ lib.optionals config.virtualisation.docker.enable [ "docker" ]
        ++ lib.optionals config.virtualisation.podman.enable [ "podman" ];
    };
  };

  # programs.${shell}.enable = lib.mkForce true;
  programs = {
    fish.enable = true;
  };

  environment = {
    shells = [
      config.users.users.${username}.shell
    ];
    pathsToLink =
      lib.optionals config.home-manager.users.${username}.programs.zsh.enable [
        "/share/zsh"
      ]
      ++ lib.optionals config.home-manager.users.${username}.programs.fish.enable [
        "/share/fish"
      ];
  };
}
