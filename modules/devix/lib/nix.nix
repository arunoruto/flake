{ lib, pkgs }:

{
  lsps = {
    nixd = {
      enable = true;
      package = pkgs.unstable.nixd;
      command = lib.getExe pkgs.unstable.nixd;
      config = {
        formatting.command = [ "nix fmt" ];
      };
    };

    nil = {
      enable = true;
      package = pkgs.nil;
      command = lib.getExe pkgs.nil;
      config.nil = {
        formatting.command = [ "nix fmt" ];
        diagnostics = {
          ignored = [ ];
          excludeFiles = [ ];
        };
        nix = {
          binary = "nix";
          maxMemoryMB = 2560;
          flake = {
            autoArchive = true;
            autoEvalInputs = false;
            nixpkgsInputName = "nixpkgs";
          };
        };
      };
    };
  };

  formatters.nixfmt = {
    enable = true;
    package = pkgs.nixfmt;
    command = lib.getExe pkgs.nixfmt;
    args = [ ];
  };

  language = {
    lspServers = [
      "nixd"
      "nil"
    ];
    formatters = [ "nixfmt" ];
    tabWidth = 2;
    insertSpaces = true;
  };

  # Zed consumer metadata. The Zed "Nix" extension provides the nil/nixd
  # adapters; both are registered, with Zed's defaults kept after them ("...").
  consumerMeta.zed = {
    name = "Nix";
    extensions = [ "nix" ];
    languageServers = [
      "nil"
      "nixd"
      "..."
    ];
  };

  # OpenCode consumer metadata: file extensions handled by this language.
  consumerMeta.opencode = {
    extensions = [ ".nix" ];
  };
}
