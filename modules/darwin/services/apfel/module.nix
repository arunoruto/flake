{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.apfel;
in
{
  options.services.apfel = {
    enable = lib.mkEnableOption "apfel, the local Apple Intelligence LLM server";

    package = lib.mkPackageOption pkgs "apfel-llm" { };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "The host address to bind the server to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
      description = "The port to listen on.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "--cors"
        "--debug"
      ];
      description = ''
        Extra arguments to pass to the apfel serve command.
        See `apfel --help` for more options.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    launchd.user.agents.apfel = {
      serviceConfig = {
        ProgramArguments = [
          "${cfg.package}/bin/apfel"
          "--serve"
          "--host"
          cfg.host
          "--port"
          (toString cfg.port)
        ]
        ++ cfg.extraArgs;

        KeepAlive = true;
        RunAtLoad = true;

        # macOS launchd needs absolute paths for logs.
        # /tmp is an easy, volatile location for these.
        StandardOutPath = "/tmp/apfel.out.log";
        StandardErrorPath = "/tmp/apfel.err.log";
      };
    };
  };
}
