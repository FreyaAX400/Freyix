# Wayland desktop session: Hyprland + greetd, audio, bluetooth.
# Pairs with the home-manager module of the same name (modules/home/desktop.nix).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.freyix.desktop;
in
{
  options.freyix.desktop.enable = lib.mkEnableOption "Hyprland desktop session";

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
        user = "greeter";
      };
    };
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    security.polkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    security.rtkit.enable = true;
    hardware.bluetooth.enable = true;
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    home.packages = with pkgs; [
      kitty # kept system-wide so a failed home-manager activation still leaves a terminal
      wl-clipboard
      grim
      slurp
      xdg-utils
      brightnessctl
      wireplumber
      wiremix
    ];
  };
}
