# Hand-written for the Alienware m15 R5 so the ISO can be built on another machine.
# After install, `nixos-generate-config --no-filesystems --show-hardware-config` on the real
# machine will tell you if anything is missing.
{ lib, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];
}
