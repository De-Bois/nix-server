{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = {
    enable = mkEnableOption "ssh";

    passwordAuthentication = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable password authentication.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
        enable = true;
        ports = [ 22 ];

        settings = {
          PasswordAuthentication = cfg.passwordAuthentication;
        };
      };
  };
}