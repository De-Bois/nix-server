{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.pelican-panel;
  dir = cfg.directory;
in {
  options = {
    modules.pelican-panel = {
      enable = mkEnableOption "Pelican Panel";

      directory = mkOption {
        type = types.str;
        default = "/var/www/pelican";
        description = ''
          The directory where the Pelican Panel is installed.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.curl
      pkgs.gnutar
      pkgs.unzip
      pkgs.php83
      pkgs.php83Packages.composer
      pkgs.php83Extensions.gd
      pkgs.php83Extensions.mysqli
      pkgs.php83Extensions.mbstring
      pkgs.php83Extensions.bcmath
      pkgs.php83Extensions.xml
      pkgs.php83Extensions.curl
      pkgs.php83Extensions.zip
      pkgs.php83Extensions.intl
      pkgs.php83Extensions.sqlite3
      ( import ./pelican-install.nix { inherit pkgs; inherit dir; } )
      ( import ./pelican-update.nix { inherit pkgs; inherit dir; } )
    ];

    systemd.timers."pelican-cron" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "1m";
        Unit = "pelican-cron.service";
      };
    };

    systemd.services."pelican-cron" = {
      script = ''
        ${pkgs.php83}/bin/php ${dir}/artisan schedule:run >> /dev/null 2>&1
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };

    systemd.services.pelican-queue = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
          User = "nginx";
          Group = "nginx";
          Restart = "always";
          ExecStart = "${pkgs.php83}/bin/php ${dir}/artisan queue:work --tries=3";
          startLimitInterval = 180;
          startLimitBurst = 30;
          RestartSec = "5";
      };
    };
  };
}