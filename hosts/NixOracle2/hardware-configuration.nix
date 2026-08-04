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

  # ATENCAO -- este bloco e o motivo de duas tentativas de instalacao terem
  # falhado antes de o host subir.
  #
  # A imagem Ubuntu da OCI tem /boot em uma particao separada (XBOOTLDR, ~913M,
  # LABEL=BOOT). O `nixos-infect` roda `switch-to-configuration boot` com essa
  # particao montada, entao grub.cfg, os modulos do GRUB e os kernels vao para
  # LA. Mas o hardware-configuration.nix que ele gera declara apenas "/" e
  # "/boot/efi" -- nunca "/boot".
  #
  # Resultado: apos o reboot, /boot e um diretorio vazio na particao raiz, o
  # core image do GRUB procura /boot/grub na particao 1, nao acha, e cai num
  # prompt de rescue silencioso. O disco fica perfeito e a maquina simplesmente
  # nao boota, sem nenhuma saida no console.
  #
  # Declarar /boot explicitamente mantem GRUB e NixOS olhando para o mesmo
  # lugar. Nao remova.
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-label/UEFI";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/cloudimg-rootfs";
    fsType = "ext4";
  };

  # by-label em vez de by-uuid de proposito: os UUIDs mudam a cada instancia
  # recriada, os labels da imagem Ubuntu da OCI nao. Isso deixa este arquivo
  # reutilizavel se o host precisar ser recriado.

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
