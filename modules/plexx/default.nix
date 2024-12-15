{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.plexx;
in {
  options = {
    modules.plexx = {
      enable = mkEnableOption "Plexx";

      plexxUid = mkOption {
        type = types.str;
        default = "1000";
        description = ''
          The default uid to run the Plexx containers on.
        '';
      };

      plexxGid = mkOption {
        type = types.str;
        default = "100";
        description = ''
          The default gid to run the Plexx containers on.
        '';
      };

      downloadPath = mkOption {
        type = types.str;
        default = "/media/plexmedia/downloads";
        description = ''
          The default download path for the Plexx containers.
        '';
      };

      moviePath = mkOption {
        type = types.str;
        default = "/media/plexmedia/movies";
        description = ''
          The default movie path for the Plexx containers.
        '';
      };

      seriesPath = mkOption {
        type = types.str;
        default = "/media/plexmedia/series";
        description = ''
          The default series path for the Plexx containers.
        '';
      };

    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers = {
      # https://hub.docker.com/r/qmcgaw/gluetun
      "vpn" = {
        image = "qmcgaw/gluetun";
        extraOptions = [ "--cap-add=NET_ADMIN" ];
        ports = [
          # VPN
          "8888:8888/tcp" # HTTP Proxy 
          "8388:8388/tcp" # Shadowsocks
          "8388:8388/udp" # Shadowsocks
          # Qbittorrent
          "8090:8090/tcp" # Web UI
          # "6881:6881/tcp" # Torrenting
          # "6881:6881/udp" # Torrenting
          # Prowlarr
          "9696:9696/tcp" # Web UI
          # Radarr
          "7878:7878/tcp" # Web UI
          # Sonarr
          "8989:8989/tcp" # Web UI
          # Overseerr
          "5055:5055/tcp" # Web UI
          # Maintainerr
          "6246:6246/tcp" # Web UI
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
        serviceConfig = {
          TimeoutStopSec = "1s";
        };
      };

      # https://hub.docker.com/r/linuxserver/qbittorrent
      "qbittorrent" = {
        image = "lscr.io/linuxserver/qbittorrent:latest";
        extraOptions = [ "--network=container:vpn" ];
        volumes = [
          "/etc/plexx/qbittorrent:/config"
          "${cfg.downloadPath}:/downloads"
        ];
        environment = {
          "PUID" = cfg.plexxUid;
          "GUID" = cfg.plexxGid;
          "TZ" = "Europe/Amsterdam";
          "WEBUI_PORT" = "8090";
          # "TORRENTING_PORT" = "6881";
        };
        serviceConfig = {
          TimeoutStopSec = "1s";
        };
        dependsOn = [ "vpn" ];
      };

      # https://hub.docker.com/r/linuxserver/prowlarr
      "prowlarr" = {
        image = "lscr.io/linuxserver/prowlarr:latest";
        extraOptions = [ "--network=container:vpn" ];
        volumes = [
          "/etc/plexx/prowlarr:/config"
        ];
        environment = {
          "PUID" = cfg.plexxUid;
          "GUID" = cfg.plexxGid;
          "TZ" = "Europe/Amsterdam";
        };
        serviceConfig = {
          TimeoutStopSec = "1s";
        };
        dependsOn = [ "vpn" ];
      };

      # https://hub.docker.com/r/linuxserver/radarr
      "radarr" = {
        image = "lscr.io/linuxserver/radarr:latest";
        extraOptions = [ "--network=container:vpn" ];
        volumes = [ 
          "/etc/plexx/radarr:/config" 
          "${cfg.downloadPath}:/downloads"
          "${cfg.moviePath}:/movies" 
        ];
        environment = {
          "PUID" = cfg.plexxUid;
          "GUID" = cfg.plexxGid;
          "TZ" = "Europe/Amsterdam";
        };
        serviceConfig = {
          TimeoutStopSec = "1s";
        };
        dependsOn = [ "vpn" "qbittorrent" "prowlarr" ];
      };

      # https://hub.docker.com/r/linuxserver/sonarr
      "sonarr" = {
        image = "lscr.io/linuxserver/sonarr:latest";
        extraOptions = [ "--network=container:vpn" ];
        volumes = [ 
          "/etc/plexx/sonarr:/config" 
          "${cfg.downloadPath}:/downloads"
          "${cfg.seriesPath}:/series" ];
        environment = {
          "PUID" = cfg.plexxUid;
          "GUID" = cfg.plexxGid;
          "TZ" = "Europe/Amsterdam";
        };
        serviceConfig = {
          TimeoutStopSec = "1s";
        };
        dependsOn = [ "vpn" "qbittorrent" "prowlarr" ];
      };

      # https://hub.docker.com/r/linuxserver/overseerr
      "overseerr" = {
        image = "lscr.io/linuxserver/overseerr:latest";
        extraOptions = [ "--network=container:vpn" ];
        volumes = [ 
          "/etc/plexx/overseerr:/config" 
        ];
        environment = {
          "PUID" = cfg.plexxUid;
          "GUID" = cfg.plexxGid;
          "TZ" = "Europe/Amsterdam";
        };
        serviceConfig = {
          TimeoutStopSec = "1s";
        };
        dependsOn = [ "vpn" "radarr" "sonarr" ];
      };

      # https://hub.docker.com/r/jorenn92/maintainerr
      "mainainerr" = {
        image = "ghcr.io/jorenn92/maintainerr:latest";
        extraOptions = [ "--network=container:vpn" ];
        volumes = [ 
          "/etc/plexx/maintainerr:/opt/data" 
        ];
        environment = {
          "PUID" = cfg.plexxUid;
          "GUID" = cfg.plexxGid;
          "TZ" = "Europe/Amsterdam";
        };
        serviceConfig = {
          TimeoutStopSec = "1s";
        };
        dependsOn = [ "vpn" "radarr" "sonarr" "overseerr" ];
      };
    };
  };
}
