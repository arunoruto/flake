{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./shell
    ./programs
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
    vivid

    # zsh-autosuggestions
    # zsh-syntax-highlighting

    # nix
    unstable.nh
    nix-tree
    nix-output-monitor
    nvd
  ];
}
