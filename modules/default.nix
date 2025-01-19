{ inputs, pkgs, config, ... }:

{
  imports = [ 
    # system
    ./system/configuration.nix
    ./ssh

    # CLI
    ./tmux

    # Webserver
    ./nginx

    # tunnel
    ./cloudflared

    # services
    ./pelican-panel
    ./pelican-wings
    ./plex
    ./plexx
    ./samba-client
    ./jellyfin

    # NAS
    ./bois-nas

    #nextcloud
    ./nextcloud
    ];
}