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
            package = pkgs.nextcloud28;
            hostName = "192.168.1.100";
            #config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}";
            config.adminpassFile = "/etc/nextcloud-admin-pass";
            config.dbtype = "sqlite";
            #https = true;
            #home = "/var/lib/nextcloud";
            home = "/mnt/StoragePool/Media/NextCloud";
        };
    };
}