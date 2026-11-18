{ pkgs, ... }:
{
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./kitty.conf;
  };

}
