# nix-server
NixOS server configuration files

# Pelican panel
Install the Pelican panel in ```/var/www/pelican``` with ```sudo pelican-install```. \
Update the Pelican panel in ```/var/www/pelican``` with ```sudo pelican-update```. 

# Bois webpage
Update the bois webpage with ```sudo cp /home/bois/nix-server/boishome/* /var/www/thebois.nl/ -r```.

# Docker
Enter container as root: ```docker exec -ti <name> sh```

# To-Do: 
- [X] Backup server files 
- [X] Switch from systemd-boot to GRUB
- [X] Setup basic NixOS with flakes
- [X] Install basic packages (CLI tools)
- [X] Create users
- [X] Secrets management with sops
- [X] Create Cloudflare tunnel and connect with cloudflared
- [X] Test cloudflare tunnel 
- [X] Test WARP client
- [X] Setup NGINX config
- [X] Setup Pelican panel
   - [X] Install using composer (After working 5 hours on a known error)
   - [X] Create panel install script
   - [X] Create NGINX module for Pelican panel
   - [X] Setup Pelican panel itself 
- [X] Setup SSL certificates 
- [X] Setup Pelican wings
  - [X] Install Wings Docker container
  - [X] Turn Wings into a service
- [X] Test game servers 
- [X] Fix NAS and mountpoints
- [X] Setup Plex
- [X] Setup Plexx
- [X] DNS configuration
- [X] Initial deploy and test 
- [X] Fix SSL for plex
- [X] Set maintainerr rules
- [X] Switch domain to thebois.nl
- [X] Change wings/volumes dir to home partition
- [X] Release
- [X] Force SSL in NGINX
- [X] Make modules modular to enable multiple hosts
- [X] Add Blyatclicker

# Future ideas: 
- [ ] Check Maintainerr rules 
- [ ] Clean docker compose setup using functions 
- [ ] Blyatclicker 2.0
- [ ] Create epic Bois homepage
- [ ] Email server? 

# Partition table: 

- SSD 250 GB

| Label    	| Size   	| Mountpoint 	| Format 	|
|----------	|--------	|------------	|--------	|
| NIX_BOOT 	| 1 GB   	| /boot      	| FAT32  	|
| NIX_ROOT 	| 249 GB 	| /          	| Ext4   	|

- SSD 1000 GB

| Label    	| Size    	| Mountpoint 	| Format 	|
|----------	|---------	|------------	|--------	|
| NIX_HOME 	| 1000 GB 	| /home      	| Ext4   	|

