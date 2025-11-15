{
  pkgs,
  ...
}: {
  # Virtualising with libvirt and QEMU
  virtualisation.libvirtd = {
      enable = true;
      qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
          ovmf = {
              enable = true;
              packages = [(pkgs.OVMF.override {
                  secureBoot = true;
                  tpmSupport = true;
              }).fd];
          };
          vhostUserPackages = with pkgs; [ virtiofsd ];
      };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  programs."virt-manager".enable = true;

  #programs."win-virtio".enable = true;
  #programs."win-spice".enable = true;

}