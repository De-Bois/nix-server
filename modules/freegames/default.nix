{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.freegames;
in {
  options = {
    modules.freegames = {
      enable = mkEnableOption "Enable the docker contaner for claiming free games on Epic Games Store";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers = {
      # https://hub.docker.com/r/charlocharlie/epicgames-freegames
      "freegames" = {
        image = "charlocharlie/epicgames-freegames:latest";
        ports = [ 
          "3000:3000" 
        ];
        volumes = [
          "/etc/freegames:/usr/app/config"
        ];
        environment = { 
          "TZ" = "Europe/Amsterdam";
        };
      };
    };
  };
}
