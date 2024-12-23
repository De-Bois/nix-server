{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.ghostfolio;
in {
  options = {
    modules.ghostfolio = {
      enable = mkEnableOption "Ghostfolio";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers = {
      # https://github.com/ghostfolio/ghostfolio
      # https://docs.docker.com/reference/cli/docker/container/run/
      "ghostfolio" = {
        image = "docker.io/ghostfolio/ghostfolio:latest";
        extraOptions = [ 
          "--init"
        ];
        ports = [
          "3000:3000"
        ];
        volumes = [
          "/etc/plexx/gluetun:/gluetun"
        ];
        environment = {
          "PUID" = cfg.plexxUid;
          "GUID" = cfg.plexxGid;
          "TZ" = "Europe/Amsterdam";
          "SERVER_REGIONS" = "Netherlands";
          "VPN_SERVICE_PROVIDER" = "nordvpn";
          "VPN_TYPE" = "wireguard";
        };
        environmentFiles = [ 
          "${config.sops.secrets.wireguard_key.path}"
        ];
      };
    };
  };
}
