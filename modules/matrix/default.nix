{ inputs, pkgs, lib, config, ... }:

{
  imports = [
    ./synapse.nix
    ./synapse-admin.nix

    ./mautrix-whatsapp.nix
  ];

}
