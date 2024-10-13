{
  pkgs,
  lib,
  config,
  ...
}: let
  candy-icons = pkgs.fetchFromGitHub {
    owner = "EliverLara";
    repo = "candy-icons";
    rev = "011363a8e2bceaef7d9c6e982eb20152c6676ca9";
    sha256 = "sha256-duhMByJzLV0nM7byvpdg1Z1Uw59OEaZ96UezTyfuXzg=";
  };
in {
  options.theming.icons.enable = lib.mkEnableOption "Setup icons for theming";

  config = lib.mkIf config.theming.icons.enable {
    home.file = {
      ".local/share/icons/candy-icons" = {
        # recursive = true;
        source = "${candy-icons}";
      };
    };
  };
}
