{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # ./module.nix
    # ./omo.nix
    # ./ollama.nix
    ./theme.nix
  ];

  programs.opencode = {
    enableMcpIntegration = true;
    web = {
      # Disable on laptops, enable on desktop workstations
      enable = lib.mkDefault (config.hosts.desktop.enable && !config.hosts.laptop.enable);
      extraArgs = [
        "--port"
        "4096"
      ];
    };
    package = pkgs.unstable.opencode;
    # package = pkgs.custom.opencode;
    tui = {
      theme = "stylix";
    };
    settings = {
      permission = {
        todowrite = "allow";
        todoread = "allow";
        edit = "ask";
        write = {
          ".opencode/plans/**" = "allow";
        };
        bash = {
          ls = "allow";
          pwd = "allow";
          "git status" = "allow";
          "git diff*" = "allow";
          "git log*" = "allow";
          # "git add*" = "allow";
          "mkdir -p .opencode/plans" = "allow";
          ssh = "deny";
        };
        lsp = "deny";
      };
      # model = "github-copilot/gpt-5.3-codex";
      model = "opencode-go/deepseek-v4-pro";
      agent = {
        build.disable = true;
        plan = {
          color = "info";
          # model = "opencode-go/kimi-k2.5";
          permission = {
            todowrite = "allow";
            todoread = "allow";
            write.".opencode/plans/**" = "allow";
            bash."mkdir -p .opencode/plans" = "allow";
          };
        };
        autoaccept = {
          color = "warning";
          mode = "primary";
          permission = {
            todowrite = "allow";
            todoread = "allow";
            write = "allow";
            edit = "allow";
            bash = "allow";
            # edit = "deny";
            skill = "allow";
          };
        };
      };
      plugin = [
        "opencode-gemini-auth@latest"
        "opencode-openai-codex-auth@latest"
        # "oh-my-openagent"
      ];
    };
    agents = {
      commit = ../agents/COMMIT.md;
      summirizer = ../agents/ACADEMIC-SUMMARIZER.md;
      questioner = ../agents/ACADEMIC-QUESTIONER.md;
    };
    skills = {
      # beads = pkgs.unstable.beads.src + "/skills/beads";
      beads = pkgs.unstable.beads.src + "/claude-plugin/skills/beads";
      # caveman = pkgs.caveman + "/skills/caveman";
      commit = ../skills/commit;
      git-commit-nixpkgs = ../skills/git-commit-nixpkgs;
      devenv = ../skills/devenv;
      caveman =
        (pkgs.fetchFromGitHub {
          owner = "JuliusBrussee";
          repo = "caveman";
          tag = "v1.3.5";
          hash = "sha256-EAlKoqJuTMib+gcLscMtpS8Zzq/D/LmIRoG3g/XKThc=";
        })
        + "/plugins/caveman/skills/caveman";
    };
    context = ../AGENTS.md;
  };
}
