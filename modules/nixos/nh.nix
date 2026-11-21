# nh as the rebuild tool, plus a `rebuild` wrapper.
#   rebuild                 switch this host
#   rebuild MoLK            build-only for another host (never activates a foreign config)
#   rebuild .#MoLK          same; the .# prefix is accepted and stripped
#   rebuild --dry           extra args pass through to nh (any leading non-flag arg is the host)
{
  config,
  lib,
  pkgs,
  ...
}:
let
  rebuild = pkgs.writeShellApplication {
    name = "rebuild";
    runtimeInputs = [ pkgs.nh ];
    text = ''
      this=${config.networking.hostName}
      target=$this
      if [ $# -gt 0 ] && [[ $1 != -* ]]; then
        target=''${1#.#}
        shift
      fi
      if [ "$target" = "$this" ]; then
        verb=switch
      else
        verb=build
        echo "rebuild: $target is not this host ($this), building only" >&2
      fi
      exec nh os "$verb" -H "$target" "$@"
    '';
  };
in
{
  programs.nh = {
    enable = true;
    flake = lib.mkDefault "/home/freyaax400/Documents/Freyix"; # sets NH_OS_FLAKE; override per host if the repo lives elsewhere
  };
  environment.systemPackages = [ rebuild ];
}
