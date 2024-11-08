{
  pkgs,
  lib,
  config,
  username,
  ...
}:
let
  homedir = if pkgs.stdenv.isLinux then "/home/${username}" else throw "Only setup for Linux!";
in
{
  imports = [
    ./custom.nix
  ];

  options.yubikey = {
    enable = lib.mkEnableOption "Enable yubikey support";
    signing = lib.mkOption {
      default = "tengen";
      type = lib.types.str;
      description = "Key to be used for signing by default";
      example = lib.literalExample "awesome-key";
    };
    identifiers = lib.mkOption {
      default = { };
      type = lib.types.attrsOf lib.types.int;
      description = "Attrset of Yubikey serial numbers";
      example = lib.literalExample ''
        {
          foo = 12345678;
          bar = 87654321;
        }
      '';
    };
  };

  config = lib.mkIf config.yubikey.enable {
    yubikey.custom.enable = lib.mkDefault false;

    environment.systemPackages = with pkgs; [
      age-plugin-yubikey
      pam_u2f
      yubioath-flutter
      yubikey-manager
    ];

    services = {
      pcscd.enable = true; # smartcard device
      udev.packages = [ pkgs.yubikey-personalization ];
      yubikey-agent.enable = true;
    };

    security.pam = lib.optionalAttrs pkgs.stdenv.isLinux {
      # sshAgentAuth.enable = true;
      u2f = {
        enable = true;
        # settings = {
        origin = "NIX";
        cue = true; # Tells the user they need to press the button
        authFile = "${homedir}/.config/Yubico/u2f_keys";
        # };
      };
      services = {
        login.u2fAuth = true;
        sudo = {
          u2fAuth = true;
          sshAgentAuth = true;
        };
      };
    };
  };
}
