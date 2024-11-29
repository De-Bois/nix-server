{ inputs, pkgs, config, ... }:

{
  imports =
    [ 
     # hosts
     ./bois-server
     ./brink-server
    ];
}