{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sure;
  app = "${cfg.package}/share/sure";
  stateDir = "/var/lib/sure"; # baked into the package's tmp/log/storage links

  environment = {
    RAILS_ENV = "production";
    SELF_HOSTED = "true";
    BINDING = cfg.host;
    PORT = toString cfg.port;
    # Plain HTTP by default; behind a TLS-terminating proxy set
    # RAILS_ASSUME_SSL = "true" so cookies are marked secure.
    RAILS_FORCE_SSL = "false";
    RAILS_ASSUME_SSL = "false";
    LD_PRELOAD = "${pkgs.jemalloc}/lib/libjemalloc.so"; # as upstream's image
  }
  // lib.optionalAttrs cfg.database.createLocally {
    DB_HOST = "/run/postgresql";
    POSTGRES_USER = "sure";
    POSTGRES_DB = "sure";
  }
  // lib.optionalAttrs cfg.redis.createLocally {
    REDIS_URL = "unix://${config.services.redis.servers.sure.unixSocket}";
  }
  // cfg.environment;

  # Shared by all units: same user, env, state dir and working directory.
  common = {
    inherit environment;
    path = [ pkgs.poppler-utils ]; # pdftoppm, for PDF statement imports
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      User = "sure";
      Group = "sure";
      WorkingDirectory = app;
      StateDirectory = [
        "sure"
        "sure/log"
        "sure/storage"
        "sure/tmp"
      ];
      StateDirectoryMode = "0700";
      # Generated secrets first so the user's files can override them.
      EnvironmentFile = [ "-${stateDir}/secrets.env" ] ++ cfg.environmentFiles;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };
  };

  # SECRET_KEY_BASE plus explicit Active Record encryption keys: without the
  # latter Sure stores provider credentials (Trade Republic session, Enable
  # Banking certificate, ...) unencrypted. Losing this file makes those
  # credentials unreadable, so back it up with the database.
  generateSecrets = pkgs.writeShellScript "sure-generate-secrets" ''
    set -eu
    f=${stateDir}/secrets.env
    [ -e "$f" ] && exit 0
    umask 077
    rand() { ${lib.getExe pkgs.openssl} rand -hex "$1"; }
    cat > "$f.tmp" <<EOF
    SECRET_KEY_BASE=$(rand 64)
    ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=$(rand 32)
    ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=$(rand 32)
    ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=$(rand 32)
    EOF
    mv "$f.tmp" "$f"
  '';

  dbUnits =
    lib.optional cfg.database.createLocally "postgresql.target"
    ++ lib.optional cfg.redis.createLocally "redis-sure.service";
in
{
  options.services.sure = {
    enable = lib.mkEnableOption "Sure, a self-hosted personal finance app";

    package = lib.mkPackageOption pkgs "sure" { };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "::";
      description = "Address the web server binds to (`BINDING`).";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port the web server listens on.";
    };

    openFirewall = lib.mkEnableOption "opening {option}`services.sure.port` in the firewall";

    database.createLocally = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Create a local PostgreSQL database and role `sure`, reached over the
        Unix socket with peer authentication. Disable to point
        `DB_HOST`/`POSTGRES_*` at another server via
        {option}`services.sure.environment`.
      '';
    };

    redis.createLocally = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Run a dedicated Redis instance on a Unix socket. Disable to set
        `REDIS_URL` yourself.
      '';
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        APP_DOMAIN = "finance.example.org";
        RAILS_ASSUME_SSL = "true";
        OPENAI_URI_BASE = "http://127.0.0.1:11434/v1";
        OPENAI_MODEL = "qwen3:8b";
      };
      description = ''
        Environment variables for all Sure services, overriding the module's
        defaults. Ends up world-readable in the Nix store; put secrets in
        {option}`services.sure.environmentFiles`. See upstream's
        `.env.example` for the available settings.
      '';
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      example = [ "/run/secrets/sure.env" ];
      description = ''
        Environment files with secrets (SMTP password, API keys). They are
        read after the generated `${stateDir}/secrets.env`, so they may also
        supply `SECRET_KEY_BASE` and the `ACTIVE_RECORD_ENCRYPTION_*` keys.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "sure" ];
      ensureUsers = [
        {
          name = "sure";
          ensureDBOwnership = true;
        }
      ];
    };

    services.redis.servers.sure = lib.mkIf cfg.redis.createLocally {
      enable = true;
      user = "sure";
      port = 0;
    };

    systemd.services = {
      # Secrets and migrations; web and worker wait for it, and a package
      # update restarts it (and migrates) before them.
      sure-init = lib.recursiveUpdate common {
        description = "Sure secrets and database migrations";
        requires = dbUnits;
        after = common.after ++ dbUnits;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStartPre = generateSecrets;
          ExecStart = "${app}/bin/rails db:prepare";
        };
      };

      sure-web = lib.recursiveUpdate common {
        description = "Sure web server";
        wantedBy = [ "multi-user.target" ];
        requires = [ "sure-init.service" ] ++ dbUnits;
        after = common.after ++ [ "sure-init.service" ] ++ dbUnits;
        serviceConfig = {
          ExecStart = "${app}/bin/rails server";
          Restart = "on-failure";
        };
      };

      sure-worker = lib.recursiveUpdate common {
        description = "Sure background worker (syncs, imports, AI jobs)";
        wantedBy = [ "multi-user.target" ];
        requires = [ "sure-init.service" ] ++ dbUnits;
        after = common.after ++ [ "sure-init.service" ] ++ dbUnits;
        serviceConfig = {
          ExecStart = "${cfg.package.gems}/bin/sidekiq";
          Restart = "on-failure";
        };
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    users.users.sure = {
      isSystemUser = true;
      group = "sure";
      home = stateDir;
    };
    users.groups.sure = { };
  };
}
