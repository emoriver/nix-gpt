{ inputs, ... }:

{
  imports = [ inputs.noctalia.homeModules.default ];

  # v5: l'opzione si chiama programs.noctalia (non più programs.noctalia-shell)
  # La struttura settings è ora TOML — vedi https://docs.noctalia.dev/v5
  programs.noctalia = {
    enable = true;
    settings = {
      # --- Shell / General ---
      shell = {
        locale = "it";
        #avatar_image = "/home/emoriver/.face";
      };

/*
      # --- Tema ---
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Monochrome";  # equivalente di colorSchemes.predefinedScheme = "Monochrome"
      };

      # --- Bar principale ---
      bar.main = {
        position = "top";
        thickness = 28;          # "compact" in v4 corrisponde a una barra sottile
        radius = 8;              # equivalente approssimativo di radiusRatio = 0.2
        margin_edge = 0;
        start = [ "control-center" "sysmon" "network" "bluetooth" ];
        center = [ "workspaces" ];
        end = [ "battery" "clock" ];
      };

      # --- Widget: control-center (sostituisce ControlCenter con useDistroLogo) ---
      "widget.control-center" = {
        # useDistroLogo non esiste più in v5; usa custom_image se vuoi il logo distro
      };

      # --- Widget: sysmon (sostituisce SystemMonitor) ---
      "widget.sysmon" = {
        type = "sysmon";
        stat = "cpu_usage";
      };

      # --- Widget: workspaces (sostituisce Workspace) ---
      "widget.workspaces" = {
        display = "none";       # labelMode = "none" in v4
        hide_when_empty = false; # hideUnoccupied = false in v4
      };

      # --- Widget: battery ---
      "widget.battery" = {
        type = "battery";
        device = "auto";
        show_label = false;      # alwaysShowPercentage = false in v4
        warning_threshold = 20;
      };

      # --- Widget: clock ---
      "widget.clock" = {
        format = "{:%a %d/%m  %H:%M}"; # equivalente di formatHorizontal = "ddd dd/MM  HH:mm"
        vertical_format = "{:%H\n%M}"; # equivalente di formatVertical = "HH mm"
      };

*/      
    };
  };
}
