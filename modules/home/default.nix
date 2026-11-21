# Home-manager module pattern (same as modules/nixos):
# one concern per file, `options.freyix.<name>.enable`, body under `lib.mkIf`.
# Hosts opt in from hosts/<name>/home.nix.
{
  imports = [
    ./coding.nix
    ./desktop.nix
  ];
}
