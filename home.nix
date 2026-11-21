{ ... }:
{
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./configs/kitty.conf;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./configs/hyprland.lua;
  };

  programs.librewolf = {
    enable = true;
    settings = {
      # Keep logins and history across restarts (optional)
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "network.cookie.lifetimePolicy" = 0;

      # Relax fingerprinting protection if sites break or force light mode
      "privacy.resistFingerprinting" = false;
      "webgl.disabled" = false;
    };
  };
}
