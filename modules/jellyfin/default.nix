{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.jellyfin;
in {
  options = {
    modules.jellyfin = {
      enable = mkEnableOption "Jellyfin media server";
    };
  };

  config = mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      user = "plex";
    };    
  };
}