{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.nextcloud;
in {
  options = {
    modules.nextcloud = {
      enable = mkEnableOption "NextCloud";
    };
  };

config = mkIf cfg.enable {
        services.nextcloud = {
            enable = true;
            package = pkgs.nextcloud31;
            hostName = "hubclup.nl";
            #config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}";
            config.adminpassFile = "/etc/nextcloud-admin-pass";
            config.dbtype = "sqlite";
            port = 32500
            #https = true;
            #home = "/mnt/StoragePool/Media/NextCloud";
            #datadir = "/mnt/StoragePool/Media/NextCloud";
        };
    };
}