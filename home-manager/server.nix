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

    glow
    hexyl
    hugo
    julia
    miller
    ouch
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
