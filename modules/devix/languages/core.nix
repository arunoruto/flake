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
          type = lib.types.nullOr lib.types.package;
          default = null;
          description = "Package providing this language server.";
        };

        command = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Command used to start this language server.";
        };

        args = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Arguments passed to this language server.";
        };

        config = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "Editor-specific configuration passed to this language server.";
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
          description = "Enable this formatter.";
        };

        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = null;
          description = "Package providing this formatter.";
        };

        command = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Command used to run this formatter.";
        };

        args = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Arguments passed to this formatter.";
        };
      };
    }
  );
in
{
  options.development = {
    enable = lib.mkEnableOption "development environment integration" // {
      default = false;
    };

    autoConfigureEditors = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Automatically configure enabled editors for active languages.
        Set to false to manage editor configuration manually.
      '';
    };

    defaultEditor = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "helix"
          "zed"
        ]
      );
      default = null;
      description = ''
        Preferred editor for EDITOR/VISUAL and future default-app integrations.
        Generated editor configuration is controlled by programs.<editor>.enable.
      '';
    };

    lsps = lib.mkOption {
      type = lib.types.attrsOf lspSubmodule;
      default = { };
      description = "Reusable language server registry.";
    };

    formatters = lib.mkOption {
      type = lib.types.attrsOf formatterSubmodule;
      default = { };
      description = "Reusable formatter registry.";
    };
  };
}
