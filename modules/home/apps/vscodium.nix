{pkgs, ...}:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      continue.continue
    ];
    profiles.default.userSettings = {
      "nix.serverPath" = "nixd";
    };    
  };

/*
  # Kiro usa ~/.config/Kiro invece di ~/.config/Code,
  # quindi le settings vanno scritte direttamente lì  
  home.file.".config/Kiro/User/settings.json" = {
    force = true;
    text = builtins.toJSON {
      "kiroAgent.configureMCP" = "Disabled";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = [ "nixfmt" ];
          };
        };
      };
    };
  };
*/
}
