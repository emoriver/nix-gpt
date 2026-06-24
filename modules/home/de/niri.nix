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
    
    config = ''
      spawn-at-startup "noctalia"
      spawn-at-startup "gnome-keyring-daemon" "--start" "--components=secrets"

      prefer-no-csd

      input {
          keyboard {
              xkb {
                  layout "it"
              }
          }
      }

      // --- CONFIGURAZIONE BLUR DA DOCS NOCTALIA V4 ---
      
      // Blocco blur globale che definisce la forza del gaussian blur
      blur {
          passes 2
          offset 3.0
          noise 0.03
          saturation 1.0
      }

      // Attiva il blur su tutte le finestre/superfici (Noctalia incluso)
      window-rule {
          geometry-corner-radius 8
          clip-to-geometry
          background-effect {
              blur true
              xray false
          }
      }

      // Regola specifica per non avere l'effetto X-ray sulle superfici Noctalia
      layer-rule {
          match namespace="^noctalia-(background|launcher-overlay|dock)-.*$"
          geometry-corner-radius 8
          background-effect {
              xray false
          }
      }

      // -------------------------------------------------

      binds {
          "Mod+T" { spawn "foot"; }
          "Mod+D" { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
          "Mod+Alt+L" { spawn "noctalia" "msg" "session" "session-lock"; }
          "Mod+Q" { close-window; }

          "Mod+Left"  { focus-column-left; }
          "Mod+Right" { focus-column-right; }
          "Mod+Up"    { focus-window-up; }
          "Mod+Down"  { focus-window-down; }
          
          "Mod+Shift+Up"    { focus-workspace-up; }
          "Mod+Shift+Down"  { focus-workspace-down; }
          "Mod+Shift+Left"  { move-column-left; }
          "Mod+Shift+Right" { move-column-right; }

          "Mod+1" { focus-workspace 1; }
          "Mod+2" { focus-workspace 2; }
          "Mod+3" { focus-workspace 3; }
          
          "Mod+F"       { maximize-column; }
          "Mod+Shift+F" { fullscreen-window; }
          "Mod+Comma"   { consume-window-into-column; }
          "Mod+Period"  { expel-window-from-column; }

          "Mod+S"       { screenshot; }
          "Mod+Shift+S" { screenshot-screen; }
          "Mod+Alt+S"   { screenshot-window; }
      }
    '';
  };
}