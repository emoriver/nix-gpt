{ pkgs, ... }:

{
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
        resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
      }
      {
        timeout = 600;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events = {
      lock = "noctalia msg session session-lock";
    };
  };

  programs.niri = {
    package = pkgs.niri;
    settings = {
      spawn-at-startup = [
        { command = [ "noctalia" ]; } # Avvia l'ambiente v5
        {
          command = [
            "gnome-keyring-daemon"
            "--start"
            "--components=secrets"
          ];
        }
      ];

      prefer-no-csd = true;

      input.keyboard.xkb = {
        layout = "it";
      };

      window-rules = [
        {
          geometry-corner-radius = {
            top-left = 8.0;
            top-right = 8.0;
            bottom-left = 8.0;
            bottom-right = 8.0;
          };
          clip-to-geometry = true;
        }
      ];

      debug.honor-xdg-activation-with-invalid-serial = true;

      binds = {
        "Mod+T".action.spawn = [ "foot" ];
        "Mod+D".action.spawn = [
          "noctalia"
          "msg"
          "panel-toggle"
          "launcher"
        ];
        "Mod+Alt+L".action.spawn = [
          "noctalia"
          "msg"
          "session"
          "session-lock"
        ];
        "Mod+Q".action.close-window = { };

        # --- Navigazione Finestre ---
        "Mod+Left".action.focus-column-left = { };
        "Mod+Right".action.focus-column-right = { };
        "Mod+Up".action.focus-window-up = { };
        "Mod+Down".action.focus-window-down = { };
        "Mod+Shift+Up".action.focus-workspace-up = { };
        "Mod+Shift+Down".action.focus-workspace-down = { };
        "Mod+Shift+Left".action.move-column-left = { };
        "Mod+Shift+Right".action.move-column-right = { };

        # --- Workspace e Finestre ---
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+F".action.maximize-column = { };
        "Mod+Shift+F".action.fullscreen-window = { };
        "Mod+Comma".action.consume-window-into-column = { };
        "Mod+Period".action.expel-window-from-column = { };

        # --- Screenshot ---
        "Mod+S".action.screenshot = { };
        "Mod+Shift+S".action.screenshot-screen = { };
        "Mod+Alt+S".action.screenshot-window = { };
      };
    };
  };
}
