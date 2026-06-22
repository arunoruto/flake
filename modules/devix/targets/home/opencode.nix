# OpenCode integration for development language profiles
{
  config,
  lib,
  pkgs,
  ...
}:

let
  consumersLib = import ../../lib/consumers.nix { inherit lib; };
  opencodeLib = import ../../lib/opencode.nix { inherit lib; };

  cfg = config.development;

  languagesForOpencode = consumersLib.languagesFor "opencode" cfg.languages;
  resolvedLanguagesForOpencode = consumersLib.resolveForConsumer "opencode" cfg languagesForOpencode;

  # Build a server's launcher command. Bare command + args, unless the server
  # needs env/secret setup, in which case wrap it in a shell launcher that
  # exports them first (used for AI servers, e.g. a copilot token).
  mkCommand =
    serverName: lspOpts:
    if lspOpts.environment == { } && lspOpts.environmentScript == "" then
      [ lspOpts.command ] ++ lspOpts.args
    else
      let
        wrapper = pkgs.writeShellApplication {
          name = "devix-opencode-lsp-${serverName}";
          runtimeInputs = lib.optionals (lspOpts.package != null) [ lspOpts.package ];
          text =
            lib.optionalString (lspOpts.environmentScript != "") (lspOpts.environmentScript + "\n")
            + lib.concatStringsSep "\n" (
              lib.mapAttrsToList (k: v: "export ${k}=${lib.escapeShellArg v}") lspOpts.environment
            )
            + ''

              exec ${lib.escapeShellArg lspOpts.command} "$@"
            '';
        };
      in
      [ (lib.getExe wrapper) ] ++ lspOpts.args;

  opencodeSettings = opencodeLib.toOpencodeSettings mkCommand resolvedLanguagesForOpencode;
  hasOpencodeConfig = opencodeSettings != { };
in
{
  config = lib.mkMerge [
    {
      development.consumers.opencode.enable = lib.mkDefault (config.programs.opencode.enable or false);
    }

    (lib.mkIf
      (cfg.enable && cfg.autoConfigureEditors && cfg.consumers.opencode.enable && hasOpencodeConfig)
      {
        programs.opencode.settings = opencodeSettings;
      }
    )
  ];
}
