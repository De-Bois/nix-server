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
    networking.firewall.allowedTCPPorts = [ 3333 5432 6379 ];
    
    systemd.services.init-ghostfolio-network = {
      description = "Create the network bridge for ghostfolio.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        # Put a true at the end to prevent getting non-zero return code, which will
        # crash the whole service.
        check=$(${pkgs.docker}/bin/docker network ls | grep "ghostfolio-bridge" || true)
        if [ -z "$check" ];
          then ${pkgs.docker}/bin/docker network create ghostfolio-bridge
          else echo "ghostfolio-bridge already exists in docker"
        fi
      '';
    };

    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers = {
      # https://github.com/ghostfolio/ghostfolio
      # https://docs.docker.com/reference/cli/docker/container/run/
      "ghostfolio" = {
        image = "docker.io/ghostfolio/ghostfolio:latest";
        extraOptions = [ 
          "--init"
          "--network=ghostfolio-bridge"
          "--cap-drop=ALL"
          "--security-opt=no-new-privileges:true"
        ];
        environmentFiles = [ 
          "${config.sops.secrets.ghostfolio.path}"
        ];
        # environment = {
        #   "DATABASE_URL" = "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?connect_timeout=300&sslmode=prefer";
        #   "REDIS_HOST" = "redis";
        #   "REDIS_PASSWORD" = "${REDIS_PASSWORD}";
        # };
        ports = [
          "3333:3333"
        ];
        dependsOn = [ "postgres" "redis" ];
      };

      "postgres" = {
        image = "docker.io/library/postgres:15";
        hostname = "postgres";
        extraOptions = [
          "--network=ghostfolio-bridge"
          "--cap-drop=ALL"
          "--cap-add=CHOWN"
          "--cap-add=DAC_READ_SEARCH"
          "--cap-add=FOWNER"
          "--cap-add=SETGID"
          "--cap-add=SETUID"
          "--security-opt=no-new-privileges:true"
        ];
        environmentFiles = [ 
          "${config.sops.secrets.ghostfolio.path}"
        ];
        volumes = [
          "/etc/ghostfolio/postgres:/var/lib/postgresql/data"
        ];
        # ports = [
        #   "5432:5432"
        # ];
      };

      "redis" = {
        image = "docker.io/library/redis:alpine";
        user = "999:1000";
        extraOptions = [
          "--network=ghostfolio-bridge"
          "--cap-drop=ALL"
          "--security-opt=no-new-privileges:true"
        ];
        environmentFiles = [ 
          "${config.sops.secrets.ghostfolio.path}"
        ];
        cmd = [ "redis-server" "--requirepass" "''\${REDIS_PASSWORD}" ];
      };
    };
  };
}
