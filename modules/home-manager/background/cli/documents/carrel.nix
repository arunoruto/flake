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
      consume.enable = true;
      web.enable = true;
    };
  };
}
