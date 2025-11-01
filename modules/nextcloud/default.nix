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
              memories = pkgs.fetchNextcloudApp {
              sha512 = "ENoy9ixn+ymLhVc2il4DwrBGyC6LMxbd2krvtOEtIXJFVfEuFZdM2No1B2arSCVJOOPilezzAgc2PIjmWwtBXmRBXp1y1bpqzDHK7wUcdUpPQ6Pd1frT3/mG0OhkFY5voHFrvBXb0oGUBeYa6HSCWQ+3/dqoAdmWE/IejNjvQjNC+7MZwna7KhE5/oDef/jUFpVucUrcgpUzv1sBX1T3nfelYe5J6nLfLSVV3hZxKFxGakc6VtSKGYh5Q1mw2EC27qW7+QsyyDy/tPqqBdb+63rU8sJ37qDzuMaWNl/IY1pH1EApo+GVFOn2Kymn0YL6jVUa31iMcO+Mf/7jrethBAvzdqixkqDzDPm54RFJ7pqQ/lslleF1n8q4W9yVCwILvj2ObOtPNvNMPN59LDSm9gXkGmluVY396owQBz30uarwDeF8MGPgb0iEmF5g/ZLSfFaZISbUvvo+jSQ8tiZEkEQP1cymxe7QTn7mO8QTB9hGKqdI07EotdjySJfyS++9GeaBjvefcZZ/91Yh8Ec8M3xo7+aqscb8EH4iWULJywNqfoPEvUwwpDJQ2dFXuoMPhzfBbskcnXU/Ov9O4kwjD+W5upsFzQcfHV5TuXtuG1D3KHlPO6a+CBLJ92kzO5dWehAengIVluYW5TVvMU3gaj2Ym8ogv3cBwK8xGvK2Xm4=";
              url = "https://github.com/CollaboraOnline/richdocumentscode/releases/download/25.4.504/richdocumentscode.tar.gz";
              license = "agpl3";
              };
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