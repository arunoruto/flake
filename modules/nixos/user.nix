# NOTE:
# `dbus-send --system --dest=org.freedesktop.Accounts --type=method_call --print-reply=literal /org/freedesktop/Accounts/User$(id -u) org.freedesktop.Accounts.User.SetIconFile string:$HOME/.face`
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) username;
  shell = config.home-manager.users.${username}.shell.main;
  # gravatar = "4859e08193d7c964399632a8d55915804af07bf714a68aabe8bf2c2656c96f4a";
in
{
  # options.services.accounts-daemon.templates = {
  #   administrator = lib.mkOption {
  #     type = lib.types.attrs;
  #     description = "An administrator account template.";
  #     default = {
  #       isNormalUser = false;
  #       description = "Administrator account";
  #       extraGroups = [
  #         "wheel"
  #         "networkmanager"
  #       ];
  #       shell = pkgs.${config.home-manager.users.${username}.shell}.defaultShell;
  #     };
  #   };
  #   standard = { };
  # };
  config = {
    sops.secrets."passwords/${username}".neededForUsers = true;

    users = {
      # mutableUsers = false;
      users.${username} = {
        isNormalUser = true;
        # hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
        # shell = pkgs.${config.home-manager.users.${username}.shell};
        shell = config.home-manager.users.${username}.programs.${shell}.package;
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
        ]
        ++ lib.optionals config.virtualisation.libvirtd.enable [ "libvirtd" ]
        ++ lib.optionals config.virtualisation.incus.enable [ "incus-admin" ]
        ++ lib.optionals config.virtualisation.docker.enable [ "docker" ]
        ++ lib.optionals config.virtualisation.podman.enable [ "podman" ];

        # avatar = pkgs.fetchurl {
        #   url = "https://www.gravatar.com/avatar/${gravatar}?s=500";
        #   hash = "sha256-xSBcAE2TkZpsdo1EbZduZKHOrW+8bYqm+ZHFmtd6kak=";
        # };
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

    systemd.tmpfiles.rules = lib.optionals (config.home-manager.users.${username}.home.file ? ".face") (
      let
        account-service = pkgs.writeTextFile {
          name = "accounts-service-config-${username}";
          text = lib.generators.toINI { } {
            User = {
              Session = "gnome";
              Icon = "/var/lib/AccountsService/icons/${username}";
              SystemAccount = "false";
            };
          };
        };
      in
      [
        ''C "/var/lib/AccountsService/users/${username}" 0600 root root - ${account-service}''
        # ''L+ "/var/lib/AccountsService/users/${username}" - - - - ${account-service}''
        ''d  "/var/lib/AccountsService/icons" 0755 root root -''
        ''L+ "/var/lib/AccountsService/icons/${username}" - - - - ${
          config.home-manager.users.${username}.home.file.".face".source
        }''
      ]
    );
  };
}
