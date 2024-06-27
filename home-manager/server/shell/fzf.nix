# Some nice tips:
# https://pragmaticpineapple.com/four-useful-fzf-tricks-for-your-terminal/
{
  programs = {
    fzf = {
      enable = true;
    };

    zsh = {
      sessionVariables = {
        #FZF_DEFAULT_COMMAND = "fd --hidden --strip-cwd-prefix --exclude .git";
        #FZF_CTRL_T_COMMAND = "$FZF_DEFAULT_COMMAND";
        #FZF_ALT_C_COMMAND = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
        FZF_DEFAULT_OPTS = ''
          --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
          --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
          --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796
        '';

        FZF_CTRL_T_OPTIONS = "--prview 'bat -n --color=always --line-range :500 {}'";
        FZF_ALT_C_OPTIONS = "--prview 'lsd --tree --color=always {} | head -200'";
        # FZF_ALT_C_OPTIONS = "--prview 'eza --tree --color=always {} | head -200'";
      };

      initExtra = ''
        _fzf_comprun() {
          local command=$1
          shift

          case "$command" in
            # cd)           fzf --preview 'eza --tree --level=2 --color=always {} | head -200' "$@" ;;
            cd)           fzf --preview "lsd --tree --depth=2 --color=always {} | head -200" "$@" ;;
            export|unset) fzf --preview "'eval 'echo \$' {}" "$@" ;;
            ssh)          fzf --preview "dig {}" "$@" ;;
            *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
          esac
        }
      '';
    };
  };
}
