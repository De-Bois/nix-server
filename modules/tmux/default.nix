{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.tmux;
in
{
  options.modules.tmux = {
    enable = mkEnableOption "tmux";

    keyMode = mkOption {
      type = types.str;
      default = "vi";
      description = ''
        The default editor to use when opening a new window or pane.
      '';
    };

    clock24 = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Use 24h clock mode.
      '';
    };

    newSession = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Automatically create a new session when tmux is started.
      '';
    };

    baseIndex = mkOption {
      type = types.int;
      default = 0;
      description = ''
        The base index to use for windows and panes.
      '';
    };

    escapeTime = mkOption {
      type = types.int;
      default = 0;
      description = ''
        The time in milliseconds to wait for an escape sequence.
      '';
    };

    plugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = ''
        A list of plugins to install.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
        enable = true;
        keyMode = cfg.keyMode;
        clock24 = cfg.clock24;
        newSession = cfg.newSession;
        baseIndex = cfg.baseIndex;
        escapeTime = cfg.escapeTime;

        plugins = cfg.plugins;
      };
  };
}