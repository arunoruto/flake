{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Email hash to get the gravatar image:
  # echo -n "name@example.com" | sha256sum | awk '{print $1}'
  gravatar = "4859e08193d7c964399632a8d55915804af07bf714a68aabe8bf2c2656c96f4a";
in
{
  options.avatar.enable = lib.mkEnableOption "Set avatar image for DEs using gravatar";

  config = lib.mkIf config.avatar.enable {
    # Download a gravatar image as profile
    home.file.".face".source = pkgs.fetchurl {
      url = "https://www.gravatar.com/avatar/${gravatar}?s=500";
      hash = "sha256-xSBcAE2TkZpsdo1EbZduZKHOrW+8bYqm+ZHFmtd6kak=";
    };
  };
}
