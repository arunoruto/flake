{
  config,
  lib,
  ...
}:
let
  shell = config.home-manager.users.${config.username}.shell.main;
in
{
  sops.secrets."passwords/${config.username}".neededForUsers = true;

  users = {
    # mutableUsers = false;
    users.${config.username} = {
      isNormalUser = true;
      # hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
      # shell = pkgs.${config.home-manager.users.${username}.shell};
      shell = config.home-manager.users.${config.username}.programs.${shell}.package;
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

  # programs.${shell}.enable = lib.mkForce true;
  programs = {
    fish.enable = true;
  };

  environment = {
    sessionVariables.FLAKE = "/home/${config.username}/.config/flake";
    shells = [
      config.users.users.${config.username}.shell
    ];
    pathsToLink =
      lib.optionals config.home-manager.users.${config.username}.programs.zsh.enable [
        "/share/zsh"
      ]
      ++ lib.optionals config.home-manager.users.${config.username}.programs.fish.enable [
        "/share/fish"
      ];
  };
}

# {
#   sops.secrets."passwords/${config.username}".neededForUsers = true;

#   users = {
#     # mutableUsers = false;
#     users.${config.username} = {
#       isNormalUser = true;
#       # hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
#       # shell = pkgs.${config.home-manager.users.${username}.shell};
#       shell = config.home-manager.users.${config.username}.programs.${shell}.package;
#       description = "Mirza";
#       extraGroups = [
#         "dialout"
#         "networkmanager"
#         "wheel"
#         "scanner"
#         "lp"
#         "pipewire"
#         "audio"
#         "video"
#         "render"
#         "input"
#         "uinput"
#         "tss" # tss group has access to TPM devices
#       ];
#     };
#   };

#   # programs.${shell}.enable = lib.mkForce true;
#   programs = {
#     fish.enable = true;
#   };

#   environment = {
#     sessionVariables.FLAKE = "/home/${config.username}/.config/flake";
#     shells = [
#       config.users.users.${config.username}.shell
#     ];
#     pathsToLink =
#       lib.optionals config.home-manager.users.${config.username}.programs.zsh.enable [
#         "/share/zsh"
#       ]
#       ++ lib.optionals config.home-manager.users.${config.username}.programs.fish.enable [
#         "/share/fish"
#       ];
#   };
# }
