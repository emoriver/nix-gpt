{pkgs, ...}:

{
  programs.vscodium = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      #continue.continue
    ];
    profiles.default.userSettings = {
      "nix.serverPath" = "nixd";
    };    
  };
}
