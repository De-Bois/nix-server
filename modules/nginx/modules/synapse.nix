{ inputs, lib, config, pkgs, ... }:
with lib;
let
  name = "synapse";
  cfg = config.modules.nginx.${name};
  serverName = config.modules.nginx.domainName;
  port = cfg.port;
  enableSSL = cfg.enableSSL;
in
{
  options.modules.nginx.${name} = {
    enable = mkEnableOption "Enable ${name}";

    port = mkOption {
      type = types.int;
      default = 88;
      description = ''
        The port to use for this virtual host.
      '';
    };

    enableSSL = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable SSL for this virtual host.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ port ]; 
    services.nginx.virtualHosts."${serverName}" = {
        inherit serverName;
        listen = [{ inherit port; addr="0.0.0.0"; ssl=enableSSL; }];
        forceSSL = enableSSL;
        enableACME = enableSSL;
        locations."/".extraConfig = ''
          return 404;
        '';
        # Forward all Matrix API calls to the synapse Matrix homeserver. A trailing slash
        # *must not* be used here.
        locations."/_matrix".proxyPass = "http://[::1]:8008";
        # Forward requests for e.g. SSO and password-resets.
        locations."/_synapse/client".proxyPass = "http://[::1]:8008";
    };
  };
}
