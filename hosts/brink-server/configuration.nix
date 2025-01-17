{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      inputs.sops-nix.nixosModules.sops
      ./hardware-configuration.nix
      ../../modules/default.nix

      #inputs.home-manager.nixosModules.default
    ];

  sops.defaultSopsFile = ../../secrets/thijs-secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/etc/sops-age-key.txt";
  
  sops.secrets.cloudflared_token = {
    owner = "cloudflared";
   };

  sops.secrets.wireguard_key = {
    owner = "plex";
   };

  
  modules = {
    ssh.enable = true;
    plex.enable = true;
    cloudflared.enable = true;
    nginx.enable = true;
    plexx = {
      enable = true;
      plexxUid = toString config.users.users.thijs.uid;
      plexxGid = toString config.users.groups.users.gid;
      downloadPath = "/media/plexmedia/downloads";
      moviePath = "/mnt/StoragePool/Media/Films";
      seriesPath = "/mnt/StoragePool/Media/Series";
    };
        
  };

  environment.etc."nextcloud-admin-pass".text = "DitIsEenTest";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "localhost";
    config.adminpassFile = "/etc/nextcloud-admin-pass";
    config.dbtype = "sqlite";
    trusted_domains = [192.168.1.100];
  };

  modules.nginx = {
    #index.enable = true; # Port 85
    #panel.enable = true; # Port 443
    plex.enable = true; # Port 81
    watch.enable = true; # Port 82
    domainName = "hubclup.nl";
    #blyatclicker.enable = true; # Port 83
    #epic.enable = true; # Port 84
    #jf.enable = true; # Port 86
  };
  #fileSystems."MiniPCSchijf" = {
  #  mountPoint = "/media/MiniPCSchijf";
  #  device = "//192.168.1.14/Media";
  #  fsType = "cifs";
  #  options = [ "username=bois" "password=bois" "x-systemd.automount" "noauto" "uid=${toString config.users.users.plex.uid }" "gid=${toString config.users.groups.plex.gid}"];
  #};

  fileSystems."MiniPCSchijf" =
    { mountPoint = "/media/MiniPCSchijf";
      device = "/dev/disk/by-uuid/98943bb3-29f6-48e5-a912-354b06993122";
      fsType = "ext4";
      options = ["nofail"];
      #options = [ "x-systemd.automount" "noauto" "uid=${toString config.users.users.plex.uid }" "gid=${toString config.users.groups.plex.gid}"];
    };

  fileSystems."/mnt/StoragePool" =
  {
    device = "StoragePool";
    fsType = "zfs";
    options = ["nofail"];
  };

fileSystems."/mnt/StoragePool/Media" =
  {
    device = "StoragePool/Media";
    fsType = "zfs";
    options = ["nofail"];
  };



  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.thijs = {
    isNormalUser = true;
    description = "Thijs";
    extraGroups = [ "networkmanager" "wheel" ];
    initialPassword = "hello";
    uid = 1000;   
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "44779f7c";

}