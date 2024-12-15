{

  description = "NixOS server configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      mkSystem = packages: system: hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { 
            inherit inputs system; 
            pkgs = import packages { 
              inherit system; 
              config = { allowUnfree = true; }; 
            };
          };
          modules = [
            { networking.hostName = hostname; }
            ./modules/system/configuration.nix
            ./hosts/${hostname}/configuration.nix
          ];
        };

    in {
    nixosConfigurations = {
      bois-server = mkSystem nixpkgs "x86_64-linux" "bois-server";
      brink-server = mkSystem nixpkgs "x86_64-linux" "brink-server";
    };
  };

}