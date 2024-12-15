{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.jellyfin.jellperr;
  etc-path = "/etc/jellperr";
in {
  options = {
    modules.jellyfin.jellperr = {
      enable = mkEnableOption "Jellperr (Jellyfin downloader)";

      jellperrUid = mkOption {
        type = types.str;
        default = "1000";
        description = ''
          The default uid to run the Jellperr containers on.
        '';
      };

      jellperrGid = mkOption {
        type = types.str;
        default = "100";
        description = ''
          The default gid to run the Jellperr containers on.
        '';
      };

      downloadPath = mkOption {
        type = types.str;
        default = "/media/plexmedia/downloads";
        description = ''
          The default download path for the Jellperr containers.
        '';
      };

      moviePath = mkOption {
        type = types.str;
        default = "/media/plexmedia/movies";
        description = ''
          The default movie path for the Jellperr containers.
        '';
      };

      seriesPath = mkOption {
        type = types.str;
        default = "/media/plexmedia/series";
        description = ''
          The default series path for the Jellperr containers.
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
          # Prowlarr
          "9696:9696/tcp" # Web UI
          # Radarr
          "7878:7878/tcp" # Web UI
          # Sonarr
          "8989:8989/tcp" # Web UI
          # Jellyseerr
          "5055:5055/tcp" # Web UI
        ];
        volumes = [
          "${etc-path}/gluetun:/gluetun"
        ];
        environment = {
          "PUID" = cfg.jellperrUid;
          "GUID" = cfg.jellperrGid;
          "TZ" = "Europe/Amsterdam";
          "SERVER_REGIONS" = "Netherlands";
          "VPN_SERVICE_PROVIDER" = "nordvpn";
          "VPN_TYPE" = "wireguard";
        };
        environmentFiles = [ 
          "${config.sops.secrets.wireguard_key.path}"
        ];
      };

      # https://hub.docker.com/r/linuxserver/qbittorrent
      "qbittorrent" = {
        image = "lscr.io/linuxserver/qbittorrent:latest";
        extraOptions = [ "--network=container:vpn" ];
        volumes = [
          "${etc-path}/qbittorrent:/config"
          "${cfg.downloadPath}:/downloads"
        ];
        environment = {
          "PUID" = cfg.jellperrUid;
          "GUID" = cfg.jellperrGid;
          "TZ" = "Europe/Amsterdam";
          "WEBUI_PORT" = "8090";
        };
        dependsOn = [ "vpn" ];
      };

      # https://hub.docker.com/r/linuxserver/prowlarr
      "prowlarr" = {
        image = "lscr.io/linuxserver/prowlarr:latest";
        extraOptions = [ "--network=container:vpn" ];
        volumes = [
          "${etc-path}/prowlarr:/config"
        ];
        environment = {
          "PUID" = cfg.jellperrUid;
          "GUID" = cfg.jellperrGid;
          "TZ" = "Europe/Amsterdam";
        };
        dependsOn = [ "vpn" ];
      };

      # https://hub.docker.com/r/linuxserver/radarr
      "radarr" = {
        image = "lscr.io/linuxserver/radarr:latest";
        extraOptions = [ "--network=container:vpn" ];
        volumes = [ 
          "${etc-path}/radarr:/config" 
          "${cfg.downloadPath}:/downloads"
          "${cfg.moviePath}:/movies" 
        ];
        environment = {
          "PUID" = cfg.jellperrUid;
          "GUID" = cfg.jellperrGid;
          "TZ" = "Europe/Amsterdam";
        };
        dependsOn = [ "vpn" "qbittorrent" "prowlarr" ];
      };

      # https://hub.docker.com/r/linuxserver/sonarr
      "sonarr" = {
        image = "lscr.io/linuxserver/sonarr:latest";
        extraOptions = [ "--network=container:vpn" ];
        volumes = [ 
          "${etc-path}/sonarr:/config" 
          "${cfg.downloadPath}:/downloads"
          "${cfg.seriesPath}:/series" ];
        environment = {
          "PUID" = cfg.jellperrUid;
          "GUID" = cfg.jellperrGid;
          "TZ" = "Europe/Amsterdam";
        };
        dependsOn = [ "vpn" "qbittorrent" "prowlarr" ];
      };

      # # https://hub.docker.com/r/fallenbagel/jellyseerr
      # "jellyseerr" = {
      #   image = "fallenbagel/jellyseerr:latest";
      #   extraOptions = [ "--network=host" ];
      #   volumes = [ 
      #     "${etc-path}/jellyseerr:/app/config" 
      #   ];
      #   environment = {
      #     "LOG_LEVEL"="debug";
      #     "TZ" = "Europe/Amsterdam";
      #   };
      #   dependsOn = [ "vpn" "radarr" "sonarr" ];
      # };

      # # https://hub.docker.com/r/fallenbagel/jellyseerr
      # "jellyseerr" = {
      #   image = "fallenbagel/jellyseerr:latest";
      #   # https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach
      #   extraOptions = [ "--network=container:vpn" ];
      #   # extraOptions = [ "--network=container:vpn" "--add-host=host.docker.internal:host-gateway" ];
      #   volumes = [ 
      #     "${etc-path}/jellyseerr:/app/config" 
      #   ];
      #   environment = {
      #     "LOG_LEVEL"="debug";
      #     "TZ" = "Europe/Amsterdam";
      #   };
      #   dependsOn = [ "vpn" "radarr" "sonarr" ];
      # };

      # # https://github.com/Schaka/janitorr
      # "janitorr" = {
      #   image = "ghcr.io/schaka/janitorr:stable";
      #   extraOptions = [ "--network=container:vpn" ];
      #   volumes = [ 
      #     "${etc-path}/janitorr:/opt/data" 
      #   ];
      #   environment = {
      #     "PUID" = cfg.plexxUid;
      #     "GUID" = cfg.plexxGid;
      #     "TZ" = "Europe/Amsterdam";
      #   };
      #   serviceConfig = {
      #     TimeoutStopSec = "1s";
      #   };
      #   dependsOn = [ "vpn" "radarr" "sonarr" "overseerr" ];
      # };

    };
  };
}
