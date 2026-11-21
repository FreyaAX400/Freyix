# Steam, gamescope session and gamemode.
{ config, lib, ... }:
let
  cfg = config.freyix.gaming;
in
{
  options.freyix.gaming.enable = lib.mkEnableOption "Steam, gamescope and gamemode";

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    services.pipewire.alsa.support32Bit = true;

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = false;
    };
    programs.gamemode.enable = true;
    users.users.freyaax400.extraGroups = [ "gamemode" ];
  };
}
