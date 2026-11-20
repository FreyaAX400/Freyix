{ ... }:
{
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ../../configs/kitty.conf;
  };

  # /home is kept from Arch, so existing hypr/nvim dotfiles are already there; move them into Nix when ready.
}
