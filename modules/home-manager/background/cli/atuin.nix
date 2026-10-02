_: {

  programs.atuin = {
    # package = pkgs.unstable.atuin;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      enter_accept = true;
      sync = {
        record = true;
        common_subcommands = [
          "apt"
          "dnf"
          "docker"
          "git"
          "go"
          "ip"
          "nix"
          "podman"
          "systemctl"
          "tmux"
        ];
      };
    };
  };
}
