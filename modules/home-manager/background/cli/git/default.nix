# https://www.gerritcodereview.com/
# https://meldmerge.org/
{
  config,
  pkgs,
  lib,
  osConfig ? null,
  ...
}:
let
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
  imports = [
    ./modules/glab.nix
    ./modules/tea.nix
    ./lazygit.nix
    ./jujutsu.nix
  ];

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
          # colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };
        credential = {
          "https://git.overleaf.com".helper =
            "store --file ${config.home.homeDirectory}/.config/git/overleaf";
        };
      }
      // lib.optionalAttrs (osConfig != null) {
        # commit.gpgsign = osConfig.yubikey.enable;
        # user.signingkey = "${config.home.homeDirectory}/.ssh/id_${osConfig.yubikey.signing}_sign.pub";
        # gpg.format = "ssh";
      };

      includes = [
        {
          condition = "gitdir:~/**/nixpkgs/";
          contents = {
            feature = {
              manyFiles = true;
            };
            core = {
              fsmonitor = true;
              untrackedCache = true;
              commitGraph = true;
            };
            fetch = {
              writeCommitGraph = true;
              prune = true;
            };
          };
        }
      ];
    };

    delta = {
      enable = true;
      options = {
        side-by-side = true;
      };
    };

    gh = {
      enable = true;
      package = if config.hosts.development.enable then pkgs.unstable.gh else pkgs.gh;
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
        # gh-copilot
        # gh-dash
        (if pkgs ? "gh-pr-review" then gh-pr-review else null)
      ];
    };

    gitlab = {
      # enable = config.hosts.development.enable;
      package = if config.hosts.development.enable then pkgs.unstable.glab else pkgs.glab;
      gitCredentialHelper = {
        enable = true;
        hosts = [
          "https://gitlab.com"
          "https://gitlab.bv.e-technik.tu-dortmund.de"
        ];
      };
    };

    tea = {
      enable = config.hosts.development.enable;
      package = if config.hosts.development.enable then pkgs.unstable.tea else pkgs.tea;
      gitCredentialHelper = {
        enable = true;
        hosts = [
          "https://gitea.com"
          "https://git.bv.e-technik.tu-dortmund.de"
        ];
      };
    };

    gitui.enable = false;

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
      # glab-pkg # Gitlab CLI tool
    ]
    # ++ lib.optionals (config.hosts.desktop.enable) [
    #   pkgs.ai-commit
    #   pkgs.git-quill
    # ]
    ++ lib.optionals (config.hosts.development.enable) [
      # pkgs.ai-commit
      pkgs.git-quill
      # (pkgs.symlinkJoin {
      #   name = "gitbutler-tauri-nvidia";
      #   paths = [ pkgs.unstable.gitbutler ];
      #   buildInputs = [ pkgs.makeWrapper ];
      #   postBuild = ''
      #     wrapProgram $out/bin/gitbutler-tauri \
      #       --set WEBKIT_DISABLE_DMABUF_RENDERER 1
      #       # --set __NV_DISABLE_EXPLICIT_SYNC 1
      #   '';
      # })
    ];
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
