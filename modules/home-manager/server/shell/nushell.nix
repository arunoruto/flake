{
  programs = {
    nushell = {
      enable = true;
      # dotDir = ".config/zsh";
      shellAliases = {
        grep = "rg";
        tss = "tailscale switch (tailscale switch --list | tail -n +2 | fzf | tr -s ' ' | cut -d ' ' -f1)";
        # tsr = ''bash -c "sudo systemctl restart tailscaled.service"'';
        #tsen = "tailscale status | grep 'offers exit node' | fzf | tr -s ' ' | cut -d' ' -f2";
      };
      environmentVariables = {
        PATH = "$env.PATH | append ($env.HOME + '/.bin')";
        TEST = "1234";
      };
      # history = {
      #   size = 10000;
      #   path = "${config.xdg.dataHome}/zsh/history";
      # };

      configFile.text = ''
        # function get-pr-override() {
        #   PR_NO=$1
        #   HASH=$(curl -sL https://github.com/NixOS/nixpkgs/pull/''${PR_NO}.patch \
        #         | head -n 1 | grep -o -E -e "[0-9a-f]{40}")
        #   echo pr''${PR_NO} = "import (fetchTarball"
        #   echo "  \"\''${nixpkgs-tars}''${HASH}.tar.gz\")"
        #   echo "    { config = config.nixpkgs.config; };"
        # }

        $env.LS_COLORS = (vivid generate catppuccin-macchiato);

        # eval "tailscale completion zsh > ~/.config/zsh/_tailscale"
        # source ~/.config/zsh/_tailscale
      '';
    };
    starship.enableZshIntegration = true;
    zoxide.enableNushellIntegration = true;
    atuin.enableNushellIntegration = true;
    # thefuck.enableNushellIntegration = true;
    yazi.enableNushellIntegration = true;
    direnv.enableNushellIntegration = true;
  };
}
