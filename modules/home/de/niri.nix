{ inputs, pkgs, ... }:

{
  # Gestore inattività: spegne lo schermo dopo 5 min, sospende dopo 10 min
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300; # 5 minuti → spegni schermo
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
        resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
      }
      {
        timeout = 600; # 10 minuti → sospendi
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events = {
      lock = "noctalia-shell ipc lock";
    };
  };

  programs.niri = {
    package = pkgs.niri;
    settings = {
      spawn-at-startup = [
        { command = [ "noctalia-shell" ]; }
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
          # Angoli arrotondati
          geometry-corner-radius = {
            top-left = 16.0;
            top-right = 16.0;
            bottom-left = 16.0;
            bottom-right = 16.0;
          };
          clip-to-geometry = true;
        }
      ];

      debug.honor-xdg-activation-with-invalid-serial = true;

      #outputs."DisplayPort-1" = {
      #  scale = 1.0;
      #};

      binds = {
        "Mod+T".action.spawn = [ "foot" ];
        "Mod+D".action.spawn = [
          "noctalia"
          "ipc"
          "call"
          "launcher"
          "toggle"
        ];
        "Super+Alt+L".action.spawn = [
          "noctalia"
          "ipc"
          "lock"
        ];
        "Mod+Q".action.close-window = { };

        "Mod+Left".action.focus-column-left = { };
        "Mod+Right".action.focus-column-right = { };
        "Mod+Up".action.focus-window-up = { };
        "Mod+Down".action.focus-window-down = { };
        "Mod+Shift+Up".action.focus-workspace-up = { };
        "Mod+Shift+Down".action.focus-workspace-down = { };
        "Mod+Shift+Left".action.move-column-left = { };
        "Mod+Shift+Right".action.move-column-right = { };

        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+F".action.maximize-column = { };
        "Mod+Shift+F".action.fullscreen-window = { };
        "Mod+Comma".action.consume-window-into-column = { };
        "Mod+Period".action.expel-window-from-column = { };

        "Mod+S".action.screenshot = { };
        "Mod+Shift+S".action.screenshot-screen = { };
        "Mod+Alt+S".action.screenshot-window = { };
      };
    };
  };
}
