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
    networking.firewall.allowedTCPPorts = [ 8008 ];
    
    services.postgresql = {
      enable = true;
      initialScript = pkgs.writeText "Initial-PostgreSQL-Database" ''
        CREATE ROLE "matrix-synapse";
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
          TEMPLATE template0
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';
    };
    
    services.matrix-synapse = {
      enable = true;
      settings = {
        server_name = "thebois.nl";
        # The public base URL value must match the `base_url` value set in `clientConfig` above.
        # The default value here is based on `server_name`, so if your `server_name` is different
        # from the value of `fqdn` above, you will likely run into some mismatched domain names
        # in client applications.
        public_baseurl = "https://synapse.thebois.nl";
        listeners = [
          { port = 8008;
            bind_addresses = [ "::1" ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [ {
              names = [ "client" "federation" ];
              compress = true;
            } ];
          }
        ];
        enable_registration = true;
      };
    };
  };
}