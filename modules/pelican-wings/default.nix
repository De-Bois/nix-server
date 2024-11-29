{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.pelican-wings;
in {
  options = {
    modules.pelican-wings = {
      enable = mkEnableOption "Pelican Wings";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 8080 8443 ];
    
    virtualisation.docker.enable = true;

    environment.systemPackages = [
      ( pkgs.callPackage ./package.nix {} )
    ];

    systemd.services.pelican-wings = {
      description = "Wings Daemon";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      partOf = [ "docker.service" ];
      
      serviceConfig = {
        User = "root";
        WorkingDirectory = "/etc/pelican";
        LimitNOFILE = 4096;
        PIDFile = "/var/run/wings/daemon.pid";
        ExecStart = "/run/current-system/sw/bin/wings";
        Restart = "on-failure";
        startLimitInterval = 180;
        startLimitBurst = 30;
        RestartSec = "5";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}