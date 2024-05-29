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

  environment.sessionVariables.FLAKE = "/home/${username}/.config/nix";

  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
}
