{ ... }:
{
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./configs/kitty.conf;
  };

  programs.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./configs/hyprland.lua;
  };
}
