# Baseline every Freyix NixOS host gets. Always on (no option): if a machine
# shouldn't have this, it shouldn't import ./default.nix.
# Per-host things (hostName, timeZone, bootloader, hardware) live in hosts/<name>/.
{ pkgs, ... }:
{
  system.stateVersion = "26.05";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    allowed-users = [ "@wheel" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nixpkgs.config.allowUnfree = true;

  boot.supportedFilesystems = [ "btrfs" ];
  boot.consoleLogLevel = 3;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  networking.networkmanager.enable = true;
  i18n.defaultLocale = "en_GB.UTF-8";
  services.xserver.xkb.layout = "us";
  console.useXkbConfig = true;
  hardware.enableRedistributableFirmware = true;

  users.users.freyaax400 = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
    ];
    shell = pkgs.bash;
  };

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" ];
  };

  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    curl
    btop
    pciutils
    usbutils
    btrfs-progs
    compsize
    fastfetch
    ripgrep
    fd
    unzip
    p7zip
    jq
    lsof
    psmisc
    smartmontools
    nvme-cli
    ethtool
    inetutils
    nix-tree
  ];
}
