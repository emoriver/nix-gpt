{ pkgs, ... }:

{
  users.users.emoriver = {
    isNormalUser = true;
    description = "Andrea Riva";
    home = "/home/emoriver";
    createHome = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "git" "video" "sudo" "docker" ]; # aggiungi "docker" se lo usi
    shell = pkgs.zsh;

    #initialPassword = "nixos";
    hashedPassword = "$6$1zqJzMI1UgQinQug$sp1uVndN9MN/.azhIavPWRamncv4JHCgRKRhcCYNCMYhCnClGMYnxCn.JbVPSUs8HfduKYDKSyDTAlnd8czcd.";

    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMW7C8X/k4K9qmbvrOWorpDz0v1lPcvBTA9psCtWIOtQ emoriver@live.it"
    ];
  };
}