set -e
cp flake.nix flake.nix.bak; cp disko.nix disko.nix.bak; cp installer.nix installer.nix.bak

cat > disko.nix <<'EOF'
{ big ? "/dev/nvme0n1", small ? "/dev/nvme1n1" }:
let
  mountOpts = [ "compress=zstd" "noatime" ];
in
{
  # attribute names matter: "extra" sorts before "main", so its partition exists
  # before mkfs.btrfs references it
  disko.devices.disk = {
    main = {
      type = "disk";
      device = big;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          pool = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" "-d" "single" "-m" "raid1" "/dev/disk/by-partlabel/disk-extra-pool" ];
              subvolumes = {
                "@"     = { mountpoint = "/";        mountOptions = mountOpts; };
                "@home" = { mountpoint = "/home";    mountOptions = mountOpts; };
                "@nix"  = { mountpoint = "/nix";     mountOptions = mountOpts; };
                "@log"  = { mountpoint = "/var/log"; mountOptions = mountOpts; };
              };
            };
          };
        };
      };
    };
    extra = {
      type = "disk";
      device = small;
      content = {
        type = "gpt";
        partitions.pool = { size = "100%"; };
      };
    };
  };
}
EOF

cat > flake.nix <<'EOF'
{
  description = "MoLK";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, home-manager, ... }:
    let
      target = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          (import ./disko.nix { })
          ./hardware-configuration.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.freyaax400 = import ./home.nix;
          }
        ];
      };

      # same layout with the two drives' roles swapped, picked at install time by size
      swapped = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          (import ./disko.nix { big = "/dev/nvme1n1"; small = "/dev/nvme0n1"; })
        ];
      };
    in
    {
      nixosConfigurations.MoLK = target;
      nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit target swapped; };
        modules = [ ./installer.nix ];
      };
    };
}
EOF

cat > installer.nix <<'EOF'
{ pkgs, modulesPath, target, swapped, ... }:
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
EOF

git add -A
nix build .#nixosConfigurations.installer.config.system.build.isoImage
ls -lL result/iso/
