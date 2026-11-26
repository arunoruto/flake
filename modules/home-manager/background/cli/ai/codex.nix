{
  config,
  lib,
  pkgs,
  ...
}:
let
  configDir = if config.home.preferXdgDirectories then "${config.xdg.configHome}/codex" else ".codex";
in
{
  options.programs.codex.remoteControl = lib.mkOption {
    type = lib.types.bool;
    default = config.hosts.development.enable;
    defaultText = lib.literalExpression "config.hosts.development.enable";
    description = ''
      Run the Codex app-server with remote control as a user service. Installs
      Codex, so on a server it brings the voice runtime along (~1 GiB).
    '';
  };

  config = lib.mkIf config.programs.codex.enable {
    programs.codex = {
      # Installed on development hosts, or where remote control runs: nixpkgs
      # bundles a voice runtime (gstreamer, pulseaudio, python) that adds
      # ~800 MiB to a server, and it cannot be built without it short of
      # compiling Codex. The config and skills are still written everywhere,
      # for `nix run nixpkgs#codex`.
      package =
        if config.hosts.development.enable || config.programs.codex.remoteControl then
          pkgs.unstable.codex
        else
          null;
      # Home Manager translates disabled servers, HTTP headers and file-backed
      # environment variables into Codex's native MCP configuration.
      enableMcpIntegration = true;
      skills = config.ai.skills;
      context = builtins.readFile ./commit-attribution.md;
      settings = {
        project_doc_fallback_filenames = [ "CLAUDE.md" ];
        # Auto-review: sandboxed by default, escalations judged by a reviewer
        # model instead of a prompt (Codex's take on Claude Code's auto mode).
        approval_policy = "on-request";
        sandbox_mode = "workspace-write";
        approvals_reviewer = "auto_review";
      };
    };

    # Codex's Linux sandbox looks for bwrap on PATH before its bundled copy.
    home.packages = lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.bubblewrap;

    # Remote control (pair with `codex remote-control pair`) from the store
    # binary: `codex remote-control start` would copy Codex into
    # ~/.codex/packages, outside any GC root, and run it detached.
    systemd.user.services.codex-remote-control =
      lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.programs.codex.remoteControl)
        {
          Unit.Description = "Codex app-server with remote control";
          Service = {
            ExecStart = "${lib.getExe config.programs.codex.package} app-server --remote-control --listen unix://";
            Restart = "on-failure";
          };
          Install.WantedBy = [ "default.target" ];
        };

    # Link packaged skills directly: inspecting store paths through the skills
    # option would require building their packages during evaluation.
    home.file = {
      # Codex owns config.toml (it writes project trust and /model there), so
      # the generated settings go next to it instead. Codex does not read this
      # file yet; merging it in is still to do.
      "${configDir}/config.toml".enable = false;
      "${configDir}/config-nix.toml".source = config.home.file."${configDir}/config.toml".source;
    }
    // lib.mapAttrs' (
      name: source: lib.nameValuePair "${configDir}/skills/${name}" { inherit source; }
    ) config.ai.skillPackages;
  };
}
