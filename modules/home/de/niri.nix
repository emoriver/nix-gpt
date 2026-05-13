{ inputs, pkgs, ... }:

{
  programs.niri = {
    package = pkgs.niri;
    settings = {
      spawn-at-startup = [
        { command = [ "noctalia-shell" ]; }
      ];

      prefer-no-csd = true;

      input.keyboard.xkb = {
        layout = "it"; 
      };

      outputs."DisplayPort-1" = {
        scale = 1.0;
      };

      binds = {
        "Mod+T".action.spawn = [ "foot" ];
        "Mod+D".action.spawn = [ "noctalia-shell-ipc" "toggle" "launcher" ];
        "Super+Alt+L".action.spawn = [ "noctalia-shell-ipc" "lock" ];
        "Mod+Q".action.close-window = {};
        "Mod+Left".action.focus-column-left = {};
        "Mod+Right".action.focus-column-right = {};
        "Mod+Up".action.focus-window-up = {};
        "Mod+Down".action.focus-window-down = {};
        "Mod+Shift+Left".action.move-column-left = {};
        "Mod+Shift+Right".action.move-column-right = {};
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+F".action.maximize-column = {};
        "Mod+Shift+F".action.fullscreen-window = {};
      };
    };
  };
}