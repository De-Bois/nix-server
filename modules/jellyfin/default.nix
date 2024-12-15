{ inputs, system, lib, config, ... }:

with lib; let
  cfg = config.modules.jellyfin;

  # overlays
  overlays = [
    (import ./plugins/intro-skipper.nix)

    # (final: prev: {
    #   jellyseerr = prev.jellyseerr.overrideAttrs (old: {
    #     src = prev.fetchFromGitHub {
    #       owner = "Fallenbagel";
    #       repo = "jellyseerr";
    #       rev = "v2.1.0";
    #       sha256 = "sha256-5kaeqhjUy9Lgx4/uFcGRlAo+ROEOdTWc2m49rq8R8Hs=";
    #     };
    #   });
    # })
  ];

  pkgs = import inputs.nixpkgs { inherit system overlays;};
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
    services = {
      jellyfin = {
        enable = true;
        openFirewall = true;
        user = cfg.user;
      };
    
      # jellyseerr = {
      #   enable = true;
      #   package = pkgs.jellyseerr;
      #   openFirewall = true;
      # };
    };

    environment.systemPackages = with pkgs; [
      jellyfin
      # jellyseerr
    ];
  };
}