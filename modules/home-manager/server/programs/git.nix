# https://www.gerritcodereview.com/
# https://meldmerge.org/
{
  config,
  pkgs,
  lib,
  ...
}:
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
      # userEmail = "mirza.arnaut@tu-dortmund.de";
      lfs.enable = true;
      delta = {
        enable = true;
        options = {
          side-by-side = true;
        };
      };
      includes = [
        {
          #condition = "gitdir:~/cloudseeds/**";
          contents = {
            init.defaultBranch = "main";
          };
        }
      ];
      extraConfig = {
        # user.signingkey = "6B890C16BB7F7971";
        user.signingkey = "${config.home.homeDirectory}/.ssh/id_tengen.pub";
        gpg.format = "ssh";
        commit.gpgsign = true;
        pull.rebase = true;
        "credential \"https://gitlab.com\"" = {
          helper = "${lib.getExe glab-pkg} auth git-credential";
        };
        "credential \"https://gitlab.bv.e-technik.tu-dortmund.de\"" = {
          helper = "${lib.getExe glab-pkg} auth git-credential";
        };
      };
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      settings = {
        git_protocol = "https";
        prompt = "enabled";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
      };
    };

    lazygit = {
      enable = true;
      # settings = {
      #   gui = {
      #     theme = {
      #       activeBorderColor = [
      #         "#8aadf4"
      #         "bold"
      #       ];
      #       inactiveBorderColor = [ "#a5adcb" ];
      #       optionsTextColor = [ "#8aadf4" ];
      #       selectedLineBgColor = [ "#363a4f" ];
      #       cherryPickedCommitBgColor = [ "#494d64" ];
      #       cherryPickedCommitFgColor = [ "#8aadf4" ];
      #       unstagedChangesColor = [ "#ed8796" ];
      #       defaultFgColor = [ "#cad3f5" ];
      #       searchingActiveBorderColor = [ "#eed49f" ];
      #     };
      #     authorColors = {
      #       "*" = "#b7bdf8";
      #     };
      #   };
      # };
    }; # // builtins.fromYAML (builtins.readFile (catppuccin-lazygit + themes-mergable/${flavour}/${colour}.yml));

    bash = lib.mkIf config.programs.bash.enable {
      inherit shellAliases;
    };
    fish = lib.mkIf config.programs.fish.enable {
      inherit shellAliases;
    };
    nushell = lib.mkIf config.programs.nushell.enable {
      inherit shellAliases;
    };
    zsh = lib.mkIf config.programs.zsh.enable {
      inherit shellAliases;
    };
  };
}
