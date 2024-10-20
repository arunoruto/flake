{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./programs
    ./services
    ./shell

    ./secrets.nix
    ./ssh.nix
  ];

  ssh.enable = true;

  home.packages = with pkgs; [
    speedtest-cli

    dust
    glow
    hexyl
    hugo
    # julia
    marksman
    miller
    ncdu
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
