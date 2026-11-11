{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_gpu" "xhci_pci" "ahci" ];
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "compress=zstd:-1" ];
  };
  swapDevices = [ { device = "/swap/swapfile"; size = 4096; } ];
  nixpkgs.hostPlatform = "x86_64-linux";
}
