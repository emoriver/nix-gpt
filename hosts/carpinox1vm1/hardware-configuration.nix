{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "vmd" "nvme" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8e234321-774d-4e43-ac36-fd55219579ab";
      fsType = "btrfs";
      options = [ "rw" "relatime" "compress=zstd:3" "nossd" "discard=async" "space_cache=v2" "subvol=/@" ];
    };

  fileSystems."/.snapshots" =
    { device = "/dev/disk/by-uuid/8e234321-774d-4e43-ac36-fd55219579ab";
      fsType = "btrfs";
      options = [ "rw" "relatime" "compress=zstd:3" "nossd" "discard=async" "space_cache=v2" "subvol=/@.snapshots" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/8e234321-774d-4e43-ac36-fd55219579ab";
      fsType = "btrfs";
      options = [ "rw" "relatime" "compress=zstd:3" "nossd" "discard=async" "space_cache=v2" "subvol=/@nix" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/8e234321-774d-4e43-ac36-fd55219579ab";
      fsType = "btrfs";
      options = [ "rw" "relatime" "compress=zstd:3" "nossd" "discard=async" "space_cache=v2" "subvol=/@home" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/8e234321-774d-4e43-ac36-fd55219579ab";
      fsType = "btrfs";
      options = [ "rw" "relatime" "compress=zstd:3" "nossd" "discard=async" "space_cache=v2" "subvol=/@log" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0D73-72DB";
      fsType = "vfat";
      options = [ "rw" "relatime" "fmask=0022" "dmask=0022" "codepage=437" "iocharset=ascii" "shortname=mixed" "utf8" "errors=remount-ro" ];
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-uuid/8e234321-774d-4e43-ac36-fd55219579ab";
      fsType = "btrfs";
      options = [ "subvol=/@swap" ];
    };
  swapDevices = [ { device = "/swap/swapfile"; } ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
