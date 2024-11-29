{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.samba-client;
in {
  options = {
    modules.samba-client = {
      enable = mkEnableOption "Samba Client";
    };
  };

  config = mkIf cfg.enable {
    modules.cloudflared.enable = true;
    
    environment.systemPackages = [ pkgs.cifs-utils ];
    
    systemd.services.cloudflaredAccess = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" "systemd-resolved.service" ];
        script = "${pkgs.cloudflared}/bin/cloudflared access tcp --hostname media.hubclup.nl --url localhost:8445";
        serviceConfig = {
            Restart = "always";
            User = "cloudflared";
            Group = "cloudflared";
        };
    };
    
    fileSystems."hddthijs" = {
        mountPoint = "/mnt/hddthijs";
        device = "//localhost/Media";
        fsType = "cifs";
        options = let
            automount_opts = "nofail,x-systemd.automount,noauto";

        in ["${automount_opts},port=8445,credentials=/home/bois/thijstest" "uid=1000" ];
    };
  };
}