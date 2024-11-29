{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.bois-nas;
in {
  options = {
    modules.bois-nas = {
      enable = mkEnableOption "Bois NAS";
    };
  };

  config = mkIf cfg.enable {
    # For mount.cifs, required unless domain name resolution is not needed.
    environment.systemPackages = [ pkgs.cifs-utils ];
    fileSystems."plexmedia" = {
      mountPoint = "/media/plexmedia";
      device = "//192.168.3.10/plexmedia";
      fsType = "cifs";
      options = [ 
        "username=bois" 
        "password=bois" 
        "x-systemd.automount" 
        "noauto" 
        "x-systemd.idle-timeout=60" 
        "x-systemd.device-timeout=5s" 
        "x-systemd.mount-timeout=5s" 
        "uid=${toString config.users.users.plex.uid}" 
        "gid=${toString config.users.groups.plex.gid}"
      ];
    };
  };
}
