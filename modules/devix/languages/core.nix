{ lib, ... }:

let
  consumers = import ../lib/consumers.nix { inherit lib; };

  lspSubmodule = lib.types.submodule (
    { name, ... }:
    {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable this language server.";
        };

        kind = lib.mkOption {
          type = lib.types.enum [
            "language"
            "grammar"
            "tool"
            "ai"
          ];
          default = "language";
          description = ''
            Classification of this server, used by consumers to decide how to
            attach it (e.g. AI/grammar servers may be handled specially).
          '';
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

        environment = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = ''
            Literal environment variables to set when launching this server.
            Consumers that support it wrap the command in a shell launcher.
          '';
        };

        environmentScript = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = ''
            Shell snippet prepended to the server launcher (e.g. to read a secret
            into an env var). Used for AI servers; see lib/opencode.nix.
          '';
        };

        consumers = consumers.mkExposureOption ''
          Per-consumer exposure for this language server. Each consumer defaults
          to enabled; set e.g. `consumers.zed.enable = false` to keep this server
          out of Zed while leaving it available to Helix/OpenCode.
        '';
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

        consumers = consumers.mkExposureOption ''
          Per-consumer exposure for this formatter (see lsps.<name>.consumers).
        '';
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

    consumers = lib.mkOption {
      type = lib.types.submodule {
        options = lib.genAttrs consumers.names (
          name:
          lib.mkOption {
            type = lib.types.submodule {
              options.enable = lib.mkEnableOption "the ${name} consumer" // {
                description = ''
                  Whether the ${name} consumer is active. Adapters default this to
                  the relevant `programs.*.enable`; set it explicitly to force a
                  consumer on or off regardless of the program.
                '';
              };
            };
            default = { };
            description = "Activation state for the ${name} consumer.";
          }
        );
      };
      default = { };
      description = "Active editor/program consumers of the development configuration.";
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
