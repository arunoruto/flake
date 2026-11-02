{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.carrel.homeManagerModules.default ];

  # Paper library: `carrel` (CLI/TUI), plus two user services on Linux: the
  # Downloads watcher (`carrel consume`, notifies through the config's
  # [notify]) and the local web UI at http://127.0.0.1:7700. The library,
  # remote and tokens live in ~/.config/carrel/config.toml, kept out of this
  # repo because it holds credentials. Enabled per host.
  options.programs.carrel.enable = lib.mkEnableOption "carrel, the paper library, with its Downloads watcher and web UI";

  config = lib.mkIf config.programs.carrel.enable {
    services.carrel = {
      consume = {
        enable = true;
        # Google Scholar alerts land in scholar-alerts (a Thunderbird filter saves them as .eml) and become
        # carrel's recommendations.
        folders = [
          "${config.home.homeDirectory}/Downloads"
          "${config.home.homeDirectory}/Documents/scholar-alerts"
        ];
      };
      web.enable = true;
      # The library is shared through the Garage bucket in config.toml's [remote].
      sync.enable = true;
    };
    # The library for AI agents: search, read papers, propose summaries as drafts.
    # Off by default; on with `programs.mcp.servers.carrel.enabled = true;`.
    programs.mcp.servers.carrel = lib.mkIf config.programs.mcp.enable {
      enabled = lib.mkDefault false;
      type = "stdio";
      command = lib.getExe config.services.carrel.package;
      args = [ "mcp" ];
    };
  };
}
