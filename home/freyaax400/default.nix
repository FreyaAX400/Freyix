# Shared home-manager base for freyaax400. Per-host feature selection lives in
# hosts/<name>/home.nix (which imports this).
{
  imports = [ ../../modules/home ];

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
