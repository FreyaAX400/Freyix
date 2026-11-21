# Proprietary NVIDIA driver (closed kernel module, production branch).
{ config, lib, ... }:
let
  cfg = config.freyix.nvidia;
in
{
  options.freyix.nvidia.enable = lib.mkEnableOption "proprietary NVIDIA driver";

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };
}
