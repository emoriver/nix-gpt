{ inputs, ... }:

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    settings = {
      # --- Configurazione Generale v5 ---
      shell = {
        locale = "it";
      };

      # --- Tema v5 ---
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Monochrome"; 
      };

      # --- Gestione Sfondi Automatica ---
      wallpaper = {
        general = {
          enabled = true;
        };
      };

      # --- Barra Principale v5 ---
      bar.main = {
        position = "top";
        thickness = 30;
        radius = 8;
        margin_edge = 0;
        # Moduli base nativi della v5
        start = [ "control-center" "network" "bluetooth" ];
        center = [ "workspaces" ];
        end = [ "battery" "clock" ];
      };

      # --- Definizione singoli Widget v5 ---
      "widget.workspaces" = {
        display = "icon";       
        hide_when_empty = false;
      };

      "widget.battery" = {
        type = "battery";
        device = "auto";
        show_label = true;
      };

      "widget.clock" = {
        format = "{:%a %d/%m  %H:%M}";
      };
    };
  };
}