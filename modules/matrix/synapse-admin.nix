{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.matrix.synapse-admin;
in {
  options.modules.matrix.synapse-admin = {
    enable = mkEnableOption "Synapse admin panel";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers = {
      # https://hub.docker.com/r/qmcgaw/gluetun
      "synapse-admin" = {
        image = "awesometechnologies/synapse-admin:latest";
        ports = [ "8009:80" ];
      };
    };
  };
}
