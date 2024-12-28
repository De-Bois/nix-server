# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports = [
      inputs.sops-nix.nixosModules.sops
      ./hardware-configuration.nix
      ../../modules/default.nix
  ];

  sops.defaultSopsFile = ../../secrets/bois-secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/etc/sops-age-key.txt";
  
  sops.secrets = {
    cloudflared_token.owner = "cloudflared";
    wireguard_key.owner = "plex";
    ghostfolio = {
      sopsFile = ../../secrets/ghostfolio.env;
      format = "dotenv";
    };
  };

  modules = {
    tmux = { enable = true; plugins = [pkgs.tmuxPlugins.better-mouse-mode]; };
    ssh.enable = true;
    nginx.enable = true;
    pelican-wings.enable = true;
    cloudflared.enable = true;
    bois-nas.enable = true;
    plex.enable = true;
    plexx = {
      enable = true;
      plexxUid = toString config.users.users.plex.uid;
      plexxGid = toString config.users.groups.plex.gid;
    };
    jellyfin = {
      enable = true;
      user = "plex";
      jellperr = {
        enable = false;
        jellperrUid = toString config.users.users.plex.uid;
        jellperrGid = toString config.users.groups.plex.gid;
      };
    };
    samba-client.enable = false;
  };

  modules.nginx = {
    index.enable = true; # Port 85
    panel.enable = true; # Port 443
    plex.enable = true; # Port 81
    watch.enable = true; # Port 82
    blyatclicker.enable = true; # Port 83
    epic.enable = true; # Port 84
    jf.enable = true; # Port 86
    ghostfolio.enable = true; # Port 87
  };

  # Enable hardware acceleration for on iGPU
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware.graphics = { 
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver 
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; 

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    bois = {
      isNormalUser = true;
      uid = 1000;
      description = "De Bois";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [];
      initialPassword = "hello";
    };
  };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
