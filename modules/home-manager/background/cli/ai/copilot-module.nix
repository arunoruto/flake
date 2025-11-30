{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.copilot-cli;
  jsonFormat = pkgs.formats.json { };

  transformMcpServer = name: server: {
    name = name;
    value = {
      enabled = !(server.disabled or false);
    }
    // (
      if server ? url then
        {
          type = "http";
          url = server.url;
          tools = [ "*" ];
        }
        // (lib.optionalAttrs (server ? headers) { headers = server.headers; })
      else if server ? command then
        {
          type = "local";
          command = server.command;
          args = server.args or [ ];
          tools = [ "*" ];
        }
        // (lib.optionalAttrs (server ? env) { environment = server.env; })
      else
        { }
    );
  };

  transformedMcpServers =
    if cfg.enableMcpIntegration && config.programs.mcp.enable && config.programs.mcp.servers != { } then
      lib.listToAttrs (lib.mapAttrsToList transformMcpServer config.programs.mcp.servers)
    else
      { };
in
{
  meta.maintainers = with lib.maintainers; [ arunoruto ];

  options.programs.copilot-cli = {
    enable = lib.mkEnableOption "github-copilot-cli";

    package = lib.mkPackageOption pkgs "github-copilot-cli" { };

    enableMcpIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to integrate the MCP servers config from
        {option}`programs.mcp.servers` into
        {option}`programs.copilot-cli.mcp-settings`.

        Note: Settings defined in {option}`programs.mcp.servers` are merged
        with {option}`programs.copilot-cli.mcp-settings`, with copilot-cli settings
        taking precedence.
      '';
    };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = lib.literalExpression ''
        {
          "theme": "Default",
          "vimMode": true,
          "preferredEditor": "nvim",
          "autoAccept": true
        }
      '';
    };

    mcp-settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = lib.literalExpression ''
        {
          gh_grep = {
            type = "remote";
            url = "https://mcp.grep.app";
          };
        }
      '';
      description = "JSON MCP config for copilot-cli";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = lib.mkIf (cfg.package != null) [ cfg.package ];
      # sessionVariables.GEMINI_MODEL = cfg.defaultModel;
    };
    xdg.configFile = {
      ".copilot/config.json" = lib.mkIf (cfg.settings != { }) {
        source = jsonFormat.generate "copilot-cli-settings.json" cfg.settings;
      };
      ".copilot/mcp-config.json" = lib.mkIf (cfg.mcp-settings != { } || transformedMcpServers != { }) {
        source = jsonFormat.generate "copilot-cli-settings.json" {
          mcpServers = (lib.attrsets.recursiveUpdate transformedMcpServers cfg.settings);
        };
      };
    };
  };
}
