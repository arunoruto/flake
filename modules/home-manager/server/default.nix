{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./programs
    ./secrets.nix
    ./shell
    ./ssh.nix
  ];

  ssh.enable = true;

  home.packages = with pkgs; [
    speedtest-cli

    dust
    glow
    hexyl
    hugo
    julia
    marksman
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
