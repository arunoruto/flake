{ inputs, lib, ... }:
{
  imports = [ inputs.tapedeck.homeModules.default ];

  # Remote client for the tapedeck daemon on sado: `td` opens the TUI, browses
  # sado's library and plays it through mpv, streamed over the LAN or the
  # tailnet. No token, so only the read/stream/listen scopes are reachable;
  # deleting or rewriting things stays on sado itself. Enabled per host.
  programs.tapedeck.settings = {
    # Required by the schema, untouched in remote mode.
    library = lib.mkDefault "/unused";
    listenbrainz.user = lib.mkDefault "arunoruto";
    remote.url = lib.mkDefault "http://sado:7878";
  };
}
