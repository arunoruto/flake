{pkgs, ...}: {
  programs.btop = {
    enable = true;
  };

  home.file.".config/btop/themes".source = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "btop";
    rev = "1.0.0";
    sha256 = "";
  };
}
