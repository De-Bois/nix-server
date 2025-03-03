{ inputs, pkgs, lib, config, ... }:

{
  imports = [
    ./synapse.nix

    ./mautrix-whatsapp.nix
  ];

}
