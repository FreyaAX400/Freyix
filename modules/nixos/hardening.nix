# Host-agnostic hardening. Mirrors the Arch BladeRunner setup:
# hardened kernel, default-drop nftables, USBGuard, fprintd for sudo, no inbound sshd.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.freyix.hardening;
in
{
  options.freyix.hardening.enable = lib.mkEnableOption "host-agnostic hardening baseline";

  config = lib.mkIf cfg.enable {
    # --- kernel ---
    security.protectKernelImage = true; # kexec_load_disabled, no hibernate
    security.forcePageTableIsolation = true;
    boot.kernelParams = [
      "slab_nomerge"
      "init_on_alloc=1"
      "init_on_free=1"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"
      "vsyscall=none"
      "debugfs=off"
    ];

    boot.kernel.sysctl = {
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.sysrq" = 0;
      "kernel.unprivileged_bpf_disabled" = 1;
      "net.core.bpf_jit_harden" = 2;
      "kernel.yama.ptrace_scope" = 2;
      "kernel.perf_event_paranoid" = 2;
      "dev.tty.ldisc_autoload" = 0;
      "vm.unprivileged_userfaultfd" = 0;
      "vm.mmap_rnd_bits" = 32;
      "vm.mmap_rnd_compat_bits" = 16;
      "fs.protected_symlinks" = 1;
      "fs.protected_hardlinks" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.suid_dumpable" = 0;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_rfc1337" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
    };

    # Unused protocols / filesystems
    boot.extraModprobeConfig = lib.concatMapStrings (m: "install ${m} ${pkgs.coreutils}/bin/false\n") [
      "dccp"
      "sctp"
      "rds"
      "tipc"
      "ax25"
      "netrom"
      "rose"
      "cramfs"
      "freevxfs"
      "hfs"
      "hfsplus"
      "jffs2"
      "udf"
    ];
    systemd.coredump.enable = false;

    # --- network ---
    networking.nftables.enable = true;
    networking.firewall = {
      enable = true; # default-drop inbound
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      logRefusedConnections = false;
      checkReversePath = "loose"; # tailscale
    };
    networking.networkmanager.wifi.macAddress = "random";
    networking.networkmanager.ethernet.macAddress = "random";
    services.openssh.enable = lib.mkForce false; # access is via Tailscale SSH
    services.tailscale = {
      # base enables and sets ssh this forces a client device only
      useRoutingFeatures = "client";
    };
    services.fail2ban = {
      enable = true;
      banaction = "nftables-multiport";
      banaction-allports = "nftables-allports";
    };

    # --- access control ---
    security.apparmor.enable = true;
    security.auditd.enable = true;
    security.audit.enable = true;
    security.sudo.execWheelOnly = true;
    users.users.root.hashedPassword = "!"; # no root login, use sudo
    services.fprintd.enable = true;
    security.pam.services.sudo.fprintAuth = true;

    services.usbguard = {
      enable = true;
      presentDevicePolicy = "apply-policy";
      insertedDevicePolicy = "apply-policy";
      implicitPolicyTarget = "block";
      # rules are per-host, set in hosts/<name>/default.nix
    };

    # --- tpm / firmware ---
    security.tpm2 = {
      enable = true;
      tctiEnvironment.enable = true;
    };
    services.fwupd.enable = true;
    boot.tmp.useTmpfs = true;

    environment.systemPackages = [ pkgs.tpm2-tools ];
  };
}
