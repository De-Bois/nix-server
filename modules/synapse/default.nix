{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.synapse;
in {
  options = {
    modules.synapse = {
      enable = mkEnableOption "Synapse Matrix server";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      initialScript = pkgs.writeText "Initial-PostgreSQL-Database" ''
        CREATE ROLE "matrix-synapse";
        ALTER ROLE "asunotest" WITH LOGIN;
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
          TEMPLATE template0
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';
    };
    
    environment.systemPackages = with pkgs; [
      matrix-synapse
    ];

    services.matrix-synapse = {
      enable = true;
      extraConfigFiles = [
        config.sops.secrets.registration_shared_secret.path
      ];
      settings = {
        server_name = config.modules.nginx.domainName;
        public_baseurl = "https://${config.modules.nginx.chat.serverName}/";
        listeners = [
          { # federation
            bind_addresses  = [""];
            port = 8448;
            resources = [
              { compress = true; names = [ "client" ]; }
              { compress = false; names = [ "federation" ]; }
            ];
            tls = false;
            type = "http";
            x_forwarded = false;
          }
          { # client
            bind_addresses  = ["127.0.0.1"];
            port = 8008;
            resources = [
              { compress = true; names = [ "client" ]; }
            ];
            tls = false;
            type = "http";
            x_forwarded = true;
          }
        ];
        database.name = "psycopg2";
        registration_shared_secret_path = config.sops.secrets.registration_shared_secret.path;
        enable_registration = true;
        registration_requires_token = true;
      };
    };
  };
}
