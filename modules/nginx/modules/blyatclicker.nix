{ inputs, lib, config, pkgs, ... }:
with lib;
let
  name = "blyatclicker";
  cfg = config.modules.nginx.${name};
  serverName = "${name}.${config.modules.nginx.domainName}";
  port = cfg.port;
  enableSSL = cfg.enableSSL;
in
{
  options.modules.nginx.${name} = {
    enable = mkEnableOption "Enable ${name}";

    port = mkOption {
      type = types.int;
      default = 83;
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
        locations."/" = {
            proxyPass = "http://localhost:41062";
      };
    };

    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers = {
      # https://hub.docker.com/r/tomsik68/xampp/
      "xampp" = {
        image = "tomsik68/xampp";
        ports = [
          "41061:22" # SSH 
          "41062:80" # HTTP
        ];
        volumes = [
          "/home/bois/blyatclicker:/opt/lampp/htdocs"
          "/etc/blyatclicker/mysql:/opt/lampp/var/mysql/mydb"
        ];
      };
    };
  };
}
