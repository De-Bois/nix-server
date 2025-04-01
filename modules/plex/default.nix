{ inputs, pkgs, nixpkgs-unstable, system, lib, config, ... }:

with lib; let
  cfg = config.modules.plex;
  pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
  };
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