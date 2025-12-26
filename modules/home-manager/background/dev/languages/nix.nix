{ pkgs, lib, config, ... }:
let
  cfg = config.programs.dev;
in
{
  programs.dev.languages.nix = {
    extensions = [ ".nix" ];
    autoFormat = true;
    lspServers =
      [
        "nixd"
        "nil"
      ]
      ++ lib.optionals cfg.lsp.servers.copilot.enable [ "copilot" ];

    formatter = {
      package = pkgs.unstable.nixfmt;
      command = lib.getExe pkgs.unstable.nixfmt;
      args = [ ];
    };

    packages = with pkgs; [
      nil
      unstable.nixfmt
      unstable.nixd
    ];
  };
}
