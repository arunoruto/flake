{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.docs-mcp-server;
in
{
  options.services.docs-mcp-server = {
    enable = lib.mkEnableOption "Docs MCP Server";

    package = lib.mkPackageOption pkgs "docs-mcp-server" { };

    environment = lib.mkOption {
      type = lib.types.submodule {
        freeformType = with lib.types; attrsOf anything;
        options = {
          PORT = lib.mkOption {
            type = lib.types.port;
            default = 6280;
            description = "Port for the unified Web UI and MCP Server.";
          };
          HOST = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "Host to bind to. Use 0.0.0.0 to allow external access.";
          };
          DOCS_MCP_TELEMETRY = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable telemetry (DOCS_MCP_TELEMETRY).";
          };
          DOCS_MCP_STORE_PATH = lib.mkOption {
            type = lib.types.path;
            default = "/var/lib/docs-mcp-server";
            description = "Directory where the database and vectors will be stored.";
          };
        };
      };
      default = { };
      description = ''
        Environment variables for configuring the beszel-agent service.
        This field will end up public in /nix/store, for secret values use `environmentFile`.
        https://github.com/arabold/docs-mcp-server?tab=readme-ov-file#command-line-argument-overrides
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to an environment file containing secrets.
        Useful for OPENAI_API_KEY, ANTHROPIC_API_KEY, POSTHOG_API_KEY, etc.
      '';
    };

    verbose = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable verbose (debug) logging";
    };

    openFirewall = (lib.mkEnableOption "") // {
      description = "Whether to open the firewall port.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.docs-mcp-server = {
      description = "Docs MCP Server";
      wantedBy = [ "multi-user.target" ];

      environment =
        let
          browsers = (builtins.fromJSON (builtins.readFile "${pkgs.playwright}/browsers.json")).browsers;
          chromium-rev = (builtins.head (builtins.filter (x: x.name == "chromium") browsers)).revision;
        in
        lib.mapAttrs (_: v: if builtins.isBool v then (if v then "true" else "false") else toString v) (
          lib.attrsets.recursiveUpdate {
            HOME = cfg.environment.DOCS_MCP_STORE_PATH;
            DOCS_MCP_PROTOCOL = "http";

            # Chromium path is already wrapped in package.nix, but good to be explicit
            PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
            # PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH = lib.getExe pkgs.chromium;
            PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH = "${pkgs.playwright.browsers}/chromium-${chromium-rev}/chrome-linux/chrome";
          } cfg.environment
        );

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} ${lib.optionalString cfg.verbose "--verbose"}";

        DynamicUser = true;
        Restart = "always";
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;

        # Security & State
        StateDirectory = "docs-mcp-server";
        WorkingDirectory = cfg.environment.DOCS_MCP_STORE_PATH;

        # Hardening
        ProtectSystem = "full";
        ProtectHome = true; # See note below about scraping local files
        PrivateTmp = true;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      (
        if (builtins.hasAttr "PORT" cfg.environment) then (lib.strings.toInt cfg.environment.PORT) else 8080
      )
    ];
  };
}
