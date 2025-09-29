{ pkgs, ... }:

{
  users.users.user1 = {
    isNormalUser = true;
    description = "User One";
    extraGroups = [ "wheel" "networkmanager" "audio" "git" "video" "sudo" ]; # aggiungi "docker" se lo usi
    shell = pkgs.zsh;
    # Impostazione password (scegli UNO dei metodi):
    # 1) Temporaneo: imposterai la password con `sudo passwd user1` dopo il deploy
    # 2) Dichiarativo (consigliato): file hash esterno
    # hashedPasswordFile = "/etc/nixos/secrets/user1.hash";
  };
}