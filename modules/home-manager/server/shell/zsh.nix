# Got autocompletions? Put them under ~/.nix-profile/share/zsh/site-functions
# tailscale completion zsh &> ~/.nix-profile/share/zsh/site-functions/_tailscale
{
  config,
  pkgs,
  ...
}:
{
  programs = {
    zsh = {
      enable = true;
      dotDir = ".config/zsh";
      shellAliases = {
        grep = "rg";
        tss = "tailscale switch $(tailscale switch --list | tail -n +2 | fzf | tr -s ' ' | cut -d ' ' -f1)";
        tsr = ''bash -c "sudo systemctl restart tailscaled.service"'';
        #tsen = "tailscale status | grep 'offers exit node' | fzf | tr -s ' ' | cut -d' ' -f2";
      };
      sessionVariables = {
        XAUTHORITY = "$HOME/.Xauthority";
        # NIX_SSHOPTS = "source /etc/profile.d/nix.sh;";
        PATH = "$HOME/.bin:$PATH";
        TEST = "12345";
      };
      history = {
        # append = true;
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };
      autosuggestion.enable = true;
      enableCompletion = true;
      historySubstringSearch = {
        enable = true;
        searchDownKey = [ "^[OB" ];
        searchUpKey = [ "^[OA" ];
      };
      syntaxHighlighting = {
        enable = true;
      };
      # defaultKeymap = "vim";

      initExtra = ''
        # Variables
        export LS_COLORS="$(vivid generate gruvbox-dark)";
        export COPILOT_API_KEY="$(cat ${config.sops.secrets."tokens/copilot".path})"
        export CACHIX_AUTH_TOKEN="$(cat ${config.sops.secrets."tokens/cachix".path})"

        # Disable all sounds
        unsetopt BEEP

        # Enable autocomplete for . and ..
        zstyle ':completion:*' special-dirs true
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

        # Ctrl + left/right arrow key movement
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word

        function get-pr-override() {
          PR_NO=$1
          HASH=$(curl -sL https://github.com/NixOS/nixpkgs/pull/''${PR_NO}.patch \
                | head -n 1 | ${pkgs.gnugrep}/bin/grep -o -E -e "[0-9a-f]{40}")
          echo pr''${PR_NO} = "import (fetchTarball"
          echo "  \"\''${nixpkgs-tars}''${HASH}.tar.gz\")"
          echo "    { config = config.nixpkgs.config; };"
        }

        ## Autocompletions
        # tailscale
        # eval "tailscale completion zsh &> ~/.config/zsh/_tailscale"
        # source ~/.config/zsh/_tailscale
        # bws
        # eval "bws completions zsh &> ~/.config/zsh/_bws"
        # source ~/.config/zsh/_bws

        # >>> conda initialize >>>
        __conda_setup="$('/opt/conda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then
                . "/opt/conda/etc/profile.d/conda.sh"
            else
                export PATH="/opt/conda/bin:$PATH"
            fi
        fi
        unset __conda_setup
        # <<< conda initialize <<<
      '';

      # antidote = {
      #   enable = false;
      #   plugins = [
      #     "zsh-users/zsh-autosuggestions"
      #     "zsh-users/zsh-completions"
      #     "zsh-users/zsh-history-substring-search"
      #     "zsh-users/zsh-syntax-highlighting"
      #   ];
      # };
    };
  };
}
