{
  description = "VORONjord";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, ... }:
    let
      target = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./disko.nix
          ./hardware-configuration.nix
          ./configuration.nix
        ];
      };
    in
    {
      nixosConfigurations.VORONjord = target;

      # nix build .#nixosConfigurations.installer.config.system.build.isoImage
      nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit target; };
        modules = [ ./installer.nix ];
      };
    };
}
