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
    networking.firewall.allowedTCPPorts = [ 8008 8448 ];
    
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
        server_name = "thebois.nl";
        # The public base URL value must match the `base_url` value set in `clientConfig` above.
        # The default value here is based on `server_name`, so if your `server_name` is different
        # from the value of `fqdn` above, you will likely run into some mismatched domain names
        # in client applications.
        public_baseurl = "https://synapse.thebois.nl/";
        tls_certificate_path = "/var/lib/acme/synapse.thebois.nl/fullchain.pem";
        tls_private_key_path = "/var/lib/acme/synapse.thebois.nl/key.pem";
        listeners = [
          { # federation
            bind_addresses  = [""];
            port = 8448;
            resources = [
              { compress = true; names = [ "client" "webclient" ]; }
              { compress = false; names = [ "federation" ]; }
            ];
            tls = true;
            type = "http";
            x_forwarded = false;
          }
          { # client
            bind_addresses  = ["127.0.0.1"];
            port = 8008;
            resources = [
              { compress = true; names = [ "client" "webclient" ]; }
            ];
            tls = false;
            type = "http";
            x_forwarded = true;
          }
        ];
        database.name = "psycopg2";
        registration_shared_secret_path = config.sops.secrets.registration_shared_secret.path;
      };
    };
  };
}