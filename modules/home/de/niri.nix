{ inputs, pkgs, ... }:

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
      # CORREZIONE V5: Comando centralizzato per il lock via IPC
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
            top-left = 16.0; top-right = 16.0; bottom-left = 16.0; bottom-right = 16.0;
          };
          clip-to-geometry = true;
        }
      ];

      debug.honor-xdg-activation-with-invalid-serial = true;

      binds = {
        "Mod+T".action.spawn = [ "foot" ];
        
        # --- BINDING DI NOCTALIA V5 ---
        # 1. Corretto l'ordine sequenziale dei comandi IPC ("msg panel-toggle launcher")
        # 2. Trasformati in stringhe singole per evitare che Niri spacchi gli argomenti
        "Mod+D".action.spawn = "noctalia msg panel-toggle launcher";
        
        # 3. Sostituito Super+Alt+L con Mod+Alt+L (Sintassi nativa Niri per mostrare il tasto nello specchietto)
        "Mod+Alt+L".action.spawn = "noctalia msg session session-lock";
        
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