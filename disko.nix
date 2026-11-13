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
