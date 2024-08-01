# https://danth.github.io/stylix/
{
  config,
  pkgs,
  ...
}: {
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "green";
  };
}
