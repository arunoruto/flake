# https://www.gerritcodereview.com/
# https://meldmerge.org/
{
  config,
  pkgs,
  lib,
  ...
}@args:
let
  glab-pkg = pkgs.unstable.glab;
  shellAliases = {
    gns = "git -c commit.gpgsign=false";
    gnscm = "git -c commit.gpgsign=false commit -m";
  };
  user = {
    email = "mirza.arnaut45@gmail.com";
    name = "Mirza Arnaut";
  };
in
{
  programs = {
    git = {
      enable = true;
      userName = user.name;
      userEmail = user.email;
      lfs.enable = true;
      delta = {
        enable = true;
        options = {
          side-by-side = true;
        };
      };
      extraConfig =
        {
          core = {
            editor = "hx";
            compression = 9;
            whitespace = "error";
            preloadindex = true;
          };
          commit.template = "~/.config/git/template";
          push = {
            autoSetupRemote = true;
            default = "current";
            # followTags = true;
          };
          pull = {
            default = "current";
            rebase = true;
          };
          rebase = {
            autoStash = true;
            missingCommitsCheck = "warn";
          };
          log.abbrevCommit = true;
          init.defaultBranch = "main";
          credential = {
            "https://gitlab.com".helper = "${lib.getExe glab-pkg} auth git-credential";
            "https://gitlab.bv.e-technik.tu-dortmund.de".helper = "${lib.getExe glab-pkg} auth git-credential";
            "https://git.overleaf.com".helper =
              "store --file ${config.home.homeDirectory}/.config/git/overleaf";
          };
        }
        // lib.optionalAttrs (args ? nixosConfig) {
          # commit.gpgsign = osConfig.yubikey.enable;
          # user.signingkey = "${config.home.homeDirectory}/.ssh/id_${osConfig.yubikey.signing}_sign.pub";
          # gpg.format = "ssh";
        };
    };

    jujutsu = {
      enable = !config.hosts.tinypc.enable;
      package = pkgs.unstable.jujutsu;
      settings = {
        inherit user;
        ui = {
          default-command = [
            "log"
            "--no-pager"
            # "--reversed"
          ];
        };
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

  sops.secrets."tokens/overleaf-cred".path = "${config.home.homeDirectory}/.config/git/overleaf";

  home = {
    packages =
      [
        glab-pkg # Gitlab CLI tool
      ]
      # ++ lib.optionals (!config.hosts.tinypc.enable) (with pkgs; [ gitbutler ])
      ++ lib.optionals config.programs.jujutsu.enable (
        with pkgs.unstable;
        [
          # lazyjj
          jjui
        ]
      );
    sessionVariables =
      let
        # token = builtins.readFile (
        #   pkgs.runCommand "github-auth-token" { } ''
        #     ${lib.getExe config.programs.gh.package} auth token > $out
        #   ''
        # );
        token = "$(${lib.getExe config.programs.gh.package} auth token)";
      in
      {
        GH_AUTH_TOKEN = "${token}";
        GITHUB_TOKEN = "${token}";
      };
    file.".config/git/template".text = ''

      # feat: ✨ 
      # feat: 🔍 
      # feat: 🔗 
      # feat: 🔒 

      # fix: 🐛 
      # fix: 🐞 
      # fix: 🩹 
      # fix: 🚑️ 

      # style: 💅 
      # style: 🎨 
      # style: 💄 

      # ci: 🦊 
      # ci: 📦 

      # deploy: 🚀 
      # deploy: 📦 

      # chore: 🧹 
      # chore: 🔧 
      # chore: ⚙️ 
      # docs: 📜 

      # refactor: 🔨 
      # perf: 🚀 

      # test: 🚦 
      # debug: 🧪 

      # BREAKING CHANGE: 🚨 
      # BREAKING CHANGE: 💥 
      # BREAKING CHANGE: 💣 
    '';
  };
}
