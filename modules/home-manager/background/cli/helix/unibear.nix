{ pkgs, ... }:
{
  programs = {
    helix = {
      settings.keys.normal."C-a" = ":sh unibear add_file %{buffer_name}";
      extraPackages = with pkgs; [ unibear ];
    };
  };
}
