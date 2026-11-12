{ pkgs, modulesPath, target, ... }:
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Put the finished system and the disk script in the ISO's store: install works offline.
  isoImage.storeContents = [
    target.config.system.build.toplevel
    target.config.system.build.diskoScript
  ];
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "install-voronjord" ''
      set -euo pipefail
      lsblk -o NAME,SIZE,MODEL,SERIAL
      echo "This WIPES /dev/nvme0n1 and /dev/nvme1n1. Type YES to continue:"
      read -r answer; [ "$answer" = YES ]
      ${target.config.system.build.diskoScript}
      nixos-install --system ${target.config.system.build.toplevel} --no-root-passwd
      nixos-enter --root /mnt -c 'passwd freyaax400'
    '')
  ];
}
