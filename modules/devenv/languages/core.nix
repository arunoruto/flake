{ lib, ... }:

let
  lspSubmodule = lib.types.submodule (
    { name, ... }:
    {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable this language server.";
        };
        package = lib.mkOption {
          type = with lib.types; nullOr package;
          default = null;
          description = "The package providing this LSP.";
        };
        command = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "The command to execute the LSP.";
        };
        args = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
        };
        config = lib.mkOption {
          type = with lib.types; attrsOf anything;
          default = { };
          description = "Configuration payload passed to the LSP.";
        };
      };
    }
  );

  formatterSubmodule = lib.types.submodule (
    { name, ... }:
    {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = null;
        };
        command = lib.mkOption {
          type = lib.types.str;
          default = name;
        };
        args = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      };
    }
  );

  languageSubmodule = lib.types.submodule (
    { name, ... }:
    {
      options = {
        enable = lib.mkEnableOption "this language profile";

        lsps = lib.mkOption {
          type = lib.types.attrsOf lspSubmodule;
          default = { };
          description = "Language servers to configure.";
        };

        formatters = lib.mkOption {
          type = lib.types.attrsOf formatterSubmodule;
          default = { };
          description = "Formatters to configure (will be piped if multiple are enabled).";
        };

        tabWidth = lib.mkOption {
          type = lib.types.int;
          default = 4;
        };
        insertSpaces = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      };
    }
  );
in
{
  options.development.languages = lib.mkOption {
    type = lib.types.attrsOf languageSubmodule;
    default = { };
  };
}
