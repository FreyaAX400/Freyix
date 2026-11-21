# NixOS module pattern:
#   - one concern per file in this directory
#   - anything not needed on every host gets `options.freyix.<name>.enable`
#     and wraps its body in `config = lib.mkIf cfg.enable { ... }`
#   - hosts opt in from hosts/<name>/default.nix (e.g. `freyix.desktop.enable = true;`)
# Home-manager modules follow the same pattern in modules/home/.
{
  imports = [
    ./base.nix
    ./desktop.nix
    ./hardening.nix
    ./nh.nix
  ];
}
