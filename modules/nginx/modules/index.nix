{ inputs, lib, config, pkgs, ... }:
with lib;
let
  name = "index";
  cfg = config.modules.nginx.${name};
  serverName = config.modules.nginx.domainName;
  port = cfg.port;
  enableSSL = cfg.enableSSL;

  # SYNAPSE
  clientConfig."m.homeserver".base_url = "https://synapse.thebois.nl";
  serverConfig."m.server" = "synapse.thebois.nl:443";
  mkWellKnown = data: ''
    default_type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in
{
  options.modules.nginx.${name} = {
    enable = mkEnableOption "Enable ${name}";

    port = mkOption {
      type = types.int;
      default = 85;
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
        root = "/var/www/${serverName}/";

        # SYNAPSE
        # This section is not needed if the server_name of matrix-synapse is equal to
        # the domain (i.e. example.org from @foo:example.org) and the federation port
        # is 8448.
        # Further reference can be found in the docs about delegation under
        # https://element-hq.github.io/synapse/latest/delegate.html
        locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
        # This is usually needed for homeserver discovery (from e.g. other Matrix clients).
        # Further reference can be found in the upstream docs at
        # https://spec.matrix.org/latest/client-server-api/#getwell-knownmatrixclient
        locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
    };
  };
}
