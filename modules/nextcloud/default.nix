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
            extraApps = {
              inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks spreed;
            };
            extraAppsEnable = true;
            hostName = "cloud.hubclup.nl";
            https = true;
            database.createLocally = true;
            config = {
              adminpassFile = "${config.sops.secrets.nextcloud_admin_pass.path}";
              dbtype = "pgsql";
            };
            settings = {
              enablePreviewProviders = [
                  "OC\\Preview\\BMP"
                  "OC\\Preview\\GIF"
                  "OC\\Preview\\JPEG"
                  "OC\\Preview\\Krita"
                  "OC\\Preview\\MarkDown"
                  "OC\\Preview\\MP3"
                  "OC\\Preview\\OpenDocument"
                  "OC\\Preview\\PNG"
                  "OC\\Preview\\TXT"
                  "OC\\Preview\\XBitmap"
                  "OC\\Preview\\HEIC"
                  "OC\\Preview\\TIFF"
                ];
            };                       
        };
       #services.onlyoffice = {
       #  enable = true;
       #  hostname = "localhosts";
       #  #jwtSecretFile = config.age.secrets.onlyoffice-jwt.path;
       #};
       ##services.nginx.virtualHosts."localhost".listen = [ { addr = "127.0.0.1"; port = 8080; } ];
    };
}