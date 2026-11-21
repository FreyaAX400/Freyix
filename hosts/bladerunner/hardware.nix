{ pkgs, ... }:
let
  btrfs = [
    "compress=zstd"
    "noatime"
  ];
in
{
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/09a2c74e-4060-43ab-9462-ecd8556c7e8d";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@nixos" ] ++ btrfs;
  };
  fileSystems."/nix" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@nix" ] ++ btrfs ++ [ "nodev" ];
  };
  fileSystems."/home" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=@home"
    ]
    ++ btrfs
    ++ [
      "nosuid"
      "nodev"
    ];
  };
  fileSystems."/var/log" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=@var_log"
    ]
    ++ btrfs
    ++ [
      "nosuid"
      "nodev"
      "noexec"
    ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/32F8-61CF";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = true;
}
