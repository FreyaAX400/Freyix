# MoLK: Alienware m15 R5 (Ryzen + NVIDIA), gaming/general-purpose laptop.
{
  pkgs,
  zenKernel,
  ...
}:
{
  imports = [
    ../../modules/nixos
    (import ./disko.nix { })
    ./hardware.nix
  ];

  freyix.desktop.enable = true;
  freyix.gaming.enable = true;
  freyix.nvidia.enable = true;

  networking.hostName = "MoLK";
  time.timeZone = "America/Los_Angeles";

  # --- boot / kernel ---
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 20;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackagesFor zenKernel;
  boot.kernelParams = [
    "loglevel=3"
    "nvme_core.default_ps_max_latency_us=0" # disable APST: stops drive from sleeping into I/O errors
    "nvme_core.io_timeout=255" # tolerate slow wakes instead of failing the I/O )(if previous line is ineffective)
  ];

  hardware.cpu.amd.updateMicrocode = true;
  services.flatpak.enable = true;
  services.openssh.enable = true;
}
