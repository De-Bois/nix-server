{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.nextcloud;
in {
  options = {
    modules.nextcloud = {
      enable = mkEnableOption "NextCloud";
    };
  };

  environment.etc."nextcloud-admin-pass".text = "DitIsEenTest";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "192.168.1.100";
    config.adminpassFile = "/etc/nextcloud-admin-pass";
    config.dbtype = "sqlite";
    https = true;
    datadir = "/mnt/StoragePool/Media/NextCloud";
  };
}