{pkgs, ...}: {
  home.packages = with pkgs; [
    unstable.glab # Gitlab CLI tool
  ];

  programs = {
    git = {
      enable = true;
      userName = "arunoruto";
      userEmail = "mirza.arnaut@tu-dortmund.de";
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
        "credential \"https://gitlab.com\"" = {
          helper = "${pkgs.glab}/bin/glab auth git-credential";
        };
        "credential \"https://gitlab.bv.e-technik.tu-dortmund.de\"" = {
          helper = "${pkgs.glab}/bin/glab auth git-credential";
        };
        pull = {
          rebase = true;
        };
      };
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      settings = {
        git_protocol = "https";
        editor = "vim";
        prompt = "enabled";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
      };
    };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          theme = {
            activeBorderColor = ["#8aadf4" "bold"];
            inactiveBorderColor = ["#a5adcb"];
            optionsTextColor = ["#8aadf4"];
            selectedLineBgColor = ["#363a4f"];
            cherryPickedCommitBgColor = ["#494d64"];
            cherryPickedCommitFgColor = ["#8aadf4"];
            unstagedChangesColor = ["#ed8796"];
            defaultFgColor = ["#cad3f5"];
            searchingActiveBorderColor = ["#eed49f"];
          };
          authorColors = {
            "*" = "#b7bdf8";
          };
        };
      };
    }; #// builtins.fromYAML (builtins.readFile (catppuccin-lazygit + themes-mergable/${flavour}/${colour}.yml));
  };
}
