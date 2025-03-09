{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.matrix.mautrix-whatsapp;
in {
  options = {
    modules.matrix.mautrix-whatsapp = {
      enable = mkEnableOption "Matrix WhatsApp Bridge";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      ensureDatabases = [ "mautrix-whatsapp" ];
      ensureUsers = [
        {
          name = "mautrix-whatsapp";
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];
    };

    services.mautrix-whatsapp = {
      enable = true;
      registerToSynapse = true;
      # https://github.com/element-hq/mautrix-whatsapp/blob/element-main/example-config.yaml 
      settings = {
        homeserver = {
          address = "http://localhost:8008";
          domain = config.modules.nginx.domainName;
        };
        appservice = {
          database = {
            type = "postgres";
            # Create database and choose one 
            # uri = "postgres://user:password@host/database?sslmode=disable";
            # uri = "postgres:///dbname?host=/var/run/postgresql";
            uri = "postgres:///mautrix-whatsapp?host=/var/run/postgresql";
          };
        };
        bridge = {
          # encription = {
          #   allow = true;
          #   default = true;
          # };
          history_sync = {
            backfill = false;
          };
          permissions = {
            # "*" = "relay";
            "thebois.nl" = "user";
            "@matthijs:thebois.nl" = "admin";
          };
        };
      };
    };
  };
}
