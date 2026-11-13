{ config, lib, pkgs, zenKernel, ... }:

{
  system.stateVersion = "26.05"; # set to the release you install from; never bump it afterwards

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 14d"; };
  nixpkgs.config.allowUnfree = true;

  # --- boot / kernel ---
  boot.loader.systemd-boot = { enable = true; configurationLimit = 20; };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackagesFor zenKernel;
  boot.supportedFilesystems = [ "btrfs" ];
  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=0" # disable APST: stops the drive sleeping into I/O errors
    "nvme_core.io_timeout=255"              # tolerate slow wakes instead of failing the I/O
  ];
  services.btrfs.autoScrub = { enable = true; interval = "monthly"; fileSystems = [ "/" ]; };

  # --- host ---
  networking.hostName = "MoLK";
  networking.networkmanager.enable = true;
  time.timeZone = "United_States/Los_Angeles";
  i18n.defaultLocale = "en_GB.UTF-8";
  services.xserver.xkb.layout = "us"; # TODO: set your actual layout
  console.useXkbConfig = true;
  hardware.enableRedistributableFirmware = true;

  # --- user ---
  users.users.freyaax400 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "input" "gamemode" ];
    shell = pkgs.bash;
    # initialPassword = "changeme"; # set, log in, run passwd, remove
  };

  # --- graphics: NVIDIA only (iGPU disabled in firmware) ---
  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics = { enable = true; enable32Bit = true; };
  services.xserver.videoDrivers = [ "nvidia" ];
  services.flatpak.enable = true;
xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false; # proprietary module, matching your old nvidia-dkms setup
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    # To hold the 595.71.05 pin instead (first build fails and prints the real hashes):
    # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #   version = "595.71.05";
    #   sha256_64bit = lib.fakeHash;
    #   openSha256 = lib.fakeHash;
    #   settingsSha256 = lib.fakeHash;
    #   persistencedSha256 = lib.fakeHash;
    # };
  };

  # --- desktop ---
  programs.hyprland.enable = true;
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
      user = "greeter";
    };
  };
  xdg.portal.enable = true;
  security.polkit.enable = true;
  services.pipewire = { enable = true; alsa.enable = true; alsa.support32Bit = true; pulse.enable = true; };
  security.rtkit.enable = true;
  hardware.bluetooth.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # --- gaming ---
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = false;
  };
  programs.gamemode.enable = true;

  # --- packages ---
  environment.systemPackages = with pkgs; [
    kitty
    git neovim wget curl htop pciutils usbutils
    btrfs-progs compsize
    wl-clipboard grim slurp tailscale openssh
  ];
}
