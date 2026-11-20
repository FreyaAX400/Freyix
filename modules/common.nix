# Shared baseline for laptops/desktops that aren't gaming rigs.
# MoLK's configuration.nix still carries its own copy; fold it into this later.
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

  programs.hyprland.enable = true;
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
      user = "greeter";
    };
  };
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;
  hardware.bluetooth.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    kitty
    git
    neovim
    wget
    curl
    btop
    pciutils
    usbutils
    btrfs-progs
    compsize
    wl-clipboard
    grim
    slurp
    fastfetch
    librewolf
    xdg-utils
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
    brightnessctl
    wireplumber
    wiremix
    nh
    nix-tree
    sbctl
    tpm2-tools
  ];
}
