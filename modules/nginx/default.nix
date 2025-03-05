{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.nginx;
in
{
  imports = [
    ./modules/index.nix
    ./modules/pelican-panel.nix
    ./modules/plex.nix
    ./modules/watch.nix
    ./modules/blyatclicker.nix
    ./modules/epic.nix
    ./modules/jf.nix
    ./modules/ghostfolio.nix
    ./modules/chat.nix
    ./modules/chatmin.nix
  ];

  options.modules.nginx = {
    enable = mkEnableOption "Enable nginx";

    domainName = mkOption {
      type = types.str;
      default = "thebois.nl";
      description = ''
        The domain name to use for the nginx server.
      '';
    };

    acmeEmail = mkOption {
      type = types.str;
      default = "bois@thebois.nl";
      description = ''
        The email address to use for ACME certificates.
      '';
    };
};

  config = mkIf cfg.enable {
    services.nginx.enable = true;

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    
    security.acme.acceptTerms = true;
    security.acme.defaults.email = cfg.acmeEmail;
  };
}