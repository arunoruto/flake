{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./shell
    ./programs
    ./secrets.nix
  ];

  home.packages = with pkgs; [
    speedtest-cli

    dust
    glow
    hexyl
    hugo
    julia
    miller
    ouch
    slides
    unstable.vivid

    # zsh-autosuggestions
    # zsh-syntax-highlighting

    # nix
    unstable.nh
    nix-du
    nix-tree
    nix-output-monitor
    nvd
  ];
}
