{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.synapse;
in {
  options = {
    modules.synapse = {
      enable = mkEnableOption "Synapse Matrix server";
    };
  };

  config = mkIf cfg.enable {
    services.synapse = {
      enable = true;
    };    
  };
}