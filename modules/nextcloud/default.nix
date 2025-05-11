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
            package = pkgs.nextcloud30;
            extraApps = {
              inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks onlyoffice spreed;
            };
            hostName = "cloud.hubclup.nl";
            https = true;
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
    };
}