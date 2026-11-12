{ pkgs, ... }:
{
  home.stateVersion = "26.05"; # keep at the release you first installed; never bump
  programs.home-manager.enable = true;

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./kitty.conf; # your existing kitty.conf
  };

  # add user-level packages, git config, nvim, hypr config etc. here as you port them
}
