{ inputs, pkgs, lib, config, ... }:

with lib; let
  cfg = config.modules.jellyfin;

  # overlays
  overlays = [
    (import ./plugins/intro-skipper.nix)
  ];

in {
  imports = [
    ./jellperr
  ];

  options = {
    modules.jellyfin = {
      enable = mkEnableOption "Jellyfin media server";

      user = mkOption {
        type = types.str;
        default = "jellyfin";
        description = "The user to run the Jellyfin service as";
      };
    };
  };

  config = mkIf cfg.enable {
    pkgs.overlays = with pkgs; overlays;

    services.jellyfin = {
      enable = true;
      openFirewall = true;
      user = cfg.user;
    };

    environment.systemPackages = with pkgs; [
      jellyfin
    ];
  };
}