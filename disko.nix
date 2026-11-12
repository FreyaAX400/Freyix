# Pooled btrfs across two NVMe drives: data=single, metadata=raid1.
# Swap these for /dev/disk/by-id/... paths before running -- nvmeXn1 numbering can swap between boots.
let
  big = "/dev/nvme0n1";   # 1.75TiB
  small = "/dev/nvme1n1"; # SK hynix 1TB
  mountOpts = [ "compress=zstd" "noatime" ];
in
{
  disko.devices.disk = {
    big = {
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
              # mkfs.btrfs: second device joins the pool
              extraArgs = [ "-f" "-d" "single" "-m" "raid1" "/dev/disk/by-partlabel/disk-small-pool" ];
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
    small = {
      type = "disk";
      device = small;
      content = {
        type = "gpt";
        partitions.pool = {
          size = "100%";
          # no content: it is attached to the filesystem above via extraArgs
        };
      };
    };
  };
}
