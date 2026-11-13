{ pkgs, modulesPath, target, swapped, ... }:
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  isoImage.storeContents = [
    target.config.system.build.toplevel
    target.config.system.build.diskoScript
    swapped.config.system.build.diskoScript
  ];
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "install-voronjord" ''
      set -euo pipefail
      lsblk -o NAME,SIZE,MODEL,SERIAL
      echo "This WIPES /dev/nvme0n1 and /dev/nvme1n1. Type YES to continue:"
      read -r answer; [ "$answer" = YES ]
      a=$(lsblk -bdno SIZE /dev/nvme0n1); b=$(lsblk -bdno SIZE /dev/nvme1n1)
      if [ "$a" -gt "$b" ]; then
        ${target.config.system.build.diskoScript}
      else
        ${swapped.config.system.build.diskoScript}
      fi
      nixos-install --system ${target.config.system.build.toplevel} --no-root-passwd
      nixos-enter --root /mnt -c 'passwd freyaax400'
    '')
  ];
}
