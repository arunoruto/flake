{ pkgs, lib, config, ... }:
let
  cfg = config.programs.dev;

  bashEnabled = cfg.languages.bash.enable or false;
in
{
  programs.dev.languages = {
    bash = {
      tags = [ "shell" ];
      extensions = [ ".sh" ".bash" ];
      autoFormat = true;
      formatter = {
        package = pkgs.shfmt;
        command = lib.getExe pkgs.shfmt;
      };
      helix.languageConfig.indent = {
        tab-width = 2;
        unit = " ";
      };
    };

    fish = {
      tags = [ "shell" ];
      extensions = [ ".fish" ];
      autoFormat = true;
      lspServers = [ "fish-lsp" ];
      formatter = {
        package = config.programs.fish.package;
        command = lib.getExe' config.programs.fish.package "fish_indent";
      };
    };

    nu = {
      tags = [ "shell" ];
      extensions = [ ".nu" ];
      autoFormat = true;
      formatter = {
        package = pkgs.nufmt;
        command = lib.getExe pkgs.nufmt;
      };
    };
  };

  programs.dev.lsp.servers.bash-language-server = {
    enable = bashEnabled;
    kind = "language";
    package = pkgs.bash-language-server;
    command = lib.getExe pkgs.bash-language-server;
    args = [ "start" ];
  };

  programs.dev.languages.bash.lspServers = [ "bash-language-server" ];

  programs.dev.languages.fish.packages = with pkgs; [ fish-lsp ];
  programs.dev.languages.nu.packages = with pkgs; [ nufmt ];
  programs.dev.languages.bash.packages = with pkgs; [ bash-language-server shfmt ];
}
