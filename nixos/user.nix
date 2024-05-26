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
}
