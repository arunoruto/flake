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
      lfs.enable = true;
      settings = {
        user = {
          name = user.name;
          email = user.email;
          signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        };
        core = {
          editor = "hx";
          compression = 9;
          whitespace = "error";
          preloadindex = true;
        };
        push = {
          default = "simple";
          autoSetupRemote = true;
          followTags = true;
        };
        pull = {
          default = "current";
          rebase = true;
        };
        rebase = {
          autoStash = true;
          missingCommitsCheck = "warn";
        };
        merge.conflictstyle = "zdiff3";
        # fetch.prune = true;
        help.autocorrect = "prompt";
        commit = {
          verbose = true;
          template = "~/.config/git/template";
          gpgsign = true;
        };
        log.abbrevCommit = true;
        gpg.format = "ssh";
        alias = {
          st = "status -s";
          lol = "log --oneline --graph --decorate --all";
        };
        column.ui = "auto";
        branch.sort = "-committerdate";
        tag.sort = "version:refname";
        init.defaultBranch = "main";
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };
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
    delta = {
      enable = true;
      options = {
        side-by-side = true;
      };
    };

    jujutsu = {
      enable = config.hosts.development.enable;
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
          # theme = {
          #   activeBorderColor = [
          #     "#8aadf4"
          #     "bold"
          #   ];
          #   inactiveBorderColor = [ "#a5adcb" ];
          #   optionsTextColor = [ "#8aadf4" ];
          #   selectedLineBgColor = [ "#363a4f" ];
          #   cherryPickedCommitBgColor = [ "#494d64" ];
          #   cherryPickedCommitFgColor = [ "#8aadf4" ];
          #   unstagedChangesColor = [ "#ed8796" ];
          #   defaultFgColor = [ "#cad3f5" ];
          #   searchingActiveBorderColor = [ "#eed49f" ];
          # };
          authorColors = {
            "${user.name}" = config.lib.stylix.colors.withHashtag.base0C;
            "*" = config.lib.stylix.colors.withHashtag.base0D;
          };
        };
        customCommands = [
          {
            key = "<c-a>";
            description = "Generate AI Commit Message";
            loadingText = "Generating commit message...";
            context = "files";
            prompts = [
              {
                type = "menuFromCommand";
                key = "Provider";
                title = "Select Provider:";
                command = "ai-commit --list-providers";
              }
              {
                type = "menuFromCommand";
                key = "Model";
                title = "Select Model (optional):";
                command = "ai-commit --list-models {{.Form.Provider}}";
              }
              {
                type = "menu";
                key = "CommitStyle";
                title = "Select commit message style:";
                options = [
                  {
                    name = "Default";
                    description = "Standard conventional commit message.";
                    value = " ";
                  }
                  {
                    name = "Emoji";
                    description = "Add a GitMoji to the commit title.";
                    value = "-e";
                  }
                  {
                    name = "Brief";
                    description = "Generate a short, one-sentence summary.";
                    value = "-b";
                  }
                  {
                    name = "Brief + Emoji";
                    description = "Combine both brief and emoji styles.";
                    value = "-b -e";
                  }
                ];
              }
            ];
            command = ''
              ai-commit --non-interactive -p {{.Form.Provider}} \
                {{if and .Form.Model (ne .Form.Model "(default)") }} -m {{.Form.Model | quote}}{{end}} \
                {{.Form.CommitStyle}} \
                -o .git/LAZYGIT_PENDING_COMMIT
            '';
          }

        ];
      };
    };

    gitui = {
      enable = true;
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
    packages = [
      glab-pkg # Gitlab CLI tool
    ]
    ++ lib.optionals ((!config.hosts.tinypc.enable) && (!config.hosts.headless.enable)) [
      pkgs.ai-commit
      (pkgs.symlinkJoin {
        name = "gitbutler-tauri-nvidia";
        paths = [ pkgs.unstable.gitbutler ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/gitbutler-tauri \
            --set WEBKIT_DISABLE_DMABUF_RENDERER 1
            # --set __NV_DISABLE_EXPLICIT_SYNC 1
        '';
      })
    ]
    ++ lib.optionals config.programs.jujutsu.enable (
      with pkgs.unstable;
      [
        # lazyjj
        tea
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
