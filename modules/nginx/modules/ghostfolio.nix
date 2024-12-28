{ inputs, lib, config, pkgs, ... }:
with lib;
let
  name = "ghostfolio";
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
      default = 87;
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
    modules.ghostfolio.enable = true;

    networking.firewall.allowedTCPPorts = [ port ];
    services.nginx.virtualHosts."${serverName}" = {
      inherit serverName;
      listen = [{ inherit port; addr="0.0.0.0"; ssl=enableSSL; }];
      forceSSL = enableSSL;
      enableACME = enableSSL;
      locations."/" = {
        proxyPass = "http://localhost:3333/";
      };
    };
  };
}