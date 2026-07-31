{ lib, ... }:

let
  consumers = import ../consumers/registry.nix { inherit lib; };

  lspSubmodule = lib.types.submodule (
    { name, config, ... }:
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
          default = if config.package != null then lib.getExe config.package else name;
          defaultText = lib.literalExpression "lib.getExe package, or the registry key when there is no package";
          description = ''
            Command used to start this language server. Derived from `package`,
            so pointing `package` at a different build (an unstable one, say) is
            normally all you need. Set this explicitly when the binary is not the
            package's main program.
          '';
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
    { name, config, ... }:
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
          default = if config.package != null then lib.getExe config.package else name;
          defaultText = lib.literalExpression "lib.getExe package, or the registry key when there is no package";
          description = ''
            Command used to run this formatter. Derived from `package`; set it
            explicitly when the binary is not the package's main program.
          '';
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
  options.devix = {
    enable = lib.mkEnableOption "devix" // {
      description = ''
        Whether to let devix configure development tooling. When off, the
        language and addon definitions are still available as options but no
        editor is configured and no language server is installed.
      '';
      default = false;
    };

    autoEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Master auto-enable for consumers, analogous to Stylix's
        `stylix.autoEnable`. When true, each consumer defaults to active
        whenever its program is enabled (`devix.consumers.<name>.enable`
        defaults to `programs.<editor>.enable`). Set to false to opt out of
        automatic per-consumer enabling; you can still force an individual
        consumer on via `devix.consumers.<name>.enable = true`.
      '';
    };

    defaultEditor = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum (lib.attrNames consumers.editorCommands));
      default = null;
      description = ''
        Preferred editor for EDITOR/VISUAL and future default-app integrations.
        The candidates are the consumers that declare an `editorCommand`.
        Generated editor configuration is controlled by programs.<editor>.enable.
      '';
    };

    consumers = lib.mkOption {
      type = lib.types.submodule {
        options = lib.mapAttrs (
          name: entry:
          lib.mkOption {
            type = lib.types.submodule {
              options.enable = lib.mkEnableOption "the ${name} consumer" // {
                description = ''
                  Whether the ${name} consumer (${entry.description}) is active.
                  This defaults to the consumer's own `programs.*.enable`; set it
                  explicitly to force a consumer on or off regardless of the
                  program.
                '';
              };
            };
            default = { };
            description = "Activation state for the ${name} consumer.";
          }
        ) consumers.entries;
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
