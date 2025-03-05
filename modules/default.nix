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
    ./ghostfolio
    ./matrix-synapse

    # NAS
    ./bois-nas
    ];
}