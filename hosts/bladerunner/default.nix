{ lib, ... }:
{
  imports = [
    ../../modules/common.nix
    ../../modules/hardening.nix
    ./hardware.nix
  ];

  networking.hostName = "BladeRunner";
  time.timeZone = "Europe/Oslo";

  # Secure Boot via lanzaboote, reusing the existing sbctl keys in /var/lib/sbctl.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  services.usbguard.rules = builtins.readFile ./usbguard-rules.conf;
}
