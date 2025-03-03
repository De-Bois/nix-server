{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.matrix.mautrix-whatsapp;
in {
  options = {
    modules.matrix.mautrix-whatsapp = {
      enable = mkEnableOption "Matrix WhatsApp Bridge";
    };
  };

  config = mkIf cfg.enable {

    services.mautrix-whatsapp = {
      enable = true;
      settings = {
        homeserver = {
          address = "http://localhost:8008";
          domain = config.modules.nginx.domainName;
        }
      };
    };
  };
}
