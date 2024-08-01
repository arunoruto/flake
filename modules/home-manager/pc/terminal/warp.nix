{ ... }:
let
  catppuccin-warp = builtins.fetchGit {
    url = "https://github.com/catppuccin/warp"; 
    ref = "main";
  };
in
{
  # Theme for Warp
  home.file.".local/share/warp-terminal/themes/catppuccin" = {
    recursive = true;
    source = "${catppuccin-warp}/dist";
  };
}
