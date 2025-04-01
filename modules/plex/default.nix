{ inputs, pkgs, pkgs-unstable, system, lib, config, ... }:

with lib; let
  cfg = config.modules.plex;  
in {
  options = {
    modules.plex = {
      enable = mkEnableOption "Plex media server";
    };
  };

  config = mkIf cfg.enable {
    services.plex = {
      enable = true;
      openFirewall = true;
      package = pkgs-unstable.plex;
    };    
  };
}