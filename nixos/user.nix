{
  pkgs,
  username,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Mirza";
    extraGroups = ["dialout" "networkmanager" "wheel" "scanner" "lp" "video" "render"];
  };

  programs.zsh.enable = true;

  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
}
