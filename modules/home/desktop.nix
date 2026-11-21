# Hyprland session, kitty and LibreWolf. Pairs with modules/nixos/desktop.nix.
{ config, lib, ... }:
let
  cfg = config.freyix.desktop;
in
{
  options.freyix.desktop.enable = lib.mkEnableOption "Hyprland, kitty and LibreWolf";

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      extraConfig = builtins.readFile ../../configs/kitty.conf;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = builtins.readFile ../../configs/hyprland.lua;
    };

    programs.librewolf = {
      enable = true;
      settings = {
        # Keep logins and history across restarts
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "network.cookie.lifetimePolicy" = 0;

        # Relax fingerprinting protection if sites break or force light mode
        "privacy.resistFingerprinting" = false;
        "webgl.disabled" = false;
      };
    };
  };
}
