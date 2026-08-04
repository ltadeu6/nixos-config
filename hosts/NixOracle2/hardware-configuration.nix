{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.loader = {
    efi.efiSysMountPoint = "/boot/efi";
    grub = {
      efiSupport = true;
      # A OCI nao preserva entradas de NVRAM de forma confiavel; instalar no
      # caminho removivel (/EFI/BOOT/BOOTX64.EFI) e o que funciona nesta shape.
      efiInstallAsRemovable = true;
      device = "nodev";
    };
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/3C2C-2AEB";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  # Shape VM.Standard.E2.1.Micro: disco de boot em virtio_scsi (pci 00:04.0)
  # e NIC em virtio_net. O perfil qemu-guest.nix acima ja cobre estes modulos,
  # mas sao declarados explicitamente para o initrd nunca ficar sem o driver
  # do dispositivo raiz.
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "sd_mod"
    "uhci_hcd"
    "virtio_blk"
    "virtio_net"
    "virtio_pci"
    "virtio_scsi"
  ];
  boot.initrd.kernelModules = [ "virtio_scsi" ];
}
