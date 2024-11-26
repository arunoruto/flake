# https://www.gerritcodereview.com/
# https://meldmerge.org/
{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}@args:
let
  glab-pkg = pkgs.unstable.glab;
  shellAliases = {
    gns = "git -c commit.gpgsign=false";
  };
in
{
  home.packages = [
    glab-pkg # Gitlab CLI tool
  ];

  programs = {
    git = {
      enable = true;
      userName = "Mirza Arnaut";
      userEmail = "mirza.arnaut45@gmail.com";
      lfs.enable = true;
      delta = {
        enable = true;
        options = {
          side-by-side = true;
        };
      };
      extraConfig =
        {
          pull.rebase = true;
          init.defaultBranch = "main";
          credential = {
            "https://gitlab.com".helper = "${lib.getExe glab-pkg} auth git-credential";
            "https://gitlab.bv.e-technik.tu-dortmund.de".helper = "${lib.getExe glab-pkg} auth git-credential";
          };
        }
        // lib.optionalAttrs (args ? nixosConfig) {
          commit.gpgsign = osConfig.yubikey.enable;
          user.signingkey = "${config.home.homeDirectory}/.ssh/id_${osConfig.yubikey.signing}_sign.pub";
          gpg.format = "ssh";
        };
    };

    gh = {
      enable = true;
      # package = pkgs.unstable.gh;
      gitCredentialHelper.enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
      };
      extensions = with pkgs; [
        gh-copilot
        gh-dash
      ];
    };

    # gh-dash = {
    #   enable = true;
    #   # settings = { };
    # };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          theme = {
            activeBorderColor = [
              "#8aadf4"
              "bold"
            ];
            inactiveBorderColor = [ "#a5adcb" ];
            optionsTextColor = [ "#8aadf4" ];
            selectedLineBgColor = [ "#363a4f" ];
            cherryPickedCommitBgColor = [ "#494d64" ];
            cherryPickedCommitFgColor = [ "#8aadf4" ];
            unstagedChangesColor = [ "#ed8796" ];
            defaultFgColor = [ "#cad3f5" ];
            searchingActiveBorderColor = [ "#eed49f" ];
          };
          authorColors = {
            "*" = "#b7bdf8";
          };
        };
      };
    };

    bash = lib.mkIf config.programs.bash.enable {
      inherit shellAliases;
    };
    fish = lib.mkIf config.programs.fish.enable {
      shellAbbrs = shellAliases;
    };
    nushell = lib.mkIf config.programs.nushell.enable {
      inherit shellAliases;
    };
    zsh = lib.mkIf config.programs.zsh.enable {
      inherit shellAliases;
    };
  };
}
