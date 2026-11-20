{ config, lib, pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  imports = [
    ../../modules/common.nix
    ../../modules/hardening.nix
    ./hardware.nix
  ];

  networking.hostName = "BladeRunner";
  time.timeZone = "United_States/Los_Angeles";

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets.usbguard-rules = {
    sopsFile = ../../secrets/usbguard-rules.conf;
    format = "binary";
  };
  services.usbguard.ruleFile = config.sops.secrets.usbguard-rules.path;
}
