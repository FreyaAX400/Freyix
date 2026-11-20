{
  description = "MoLK";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-zen.url = "github:NixOS/nixpkgs/7929f16806e06c78a81d297e04cc8d03551f59fc";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      agenix,
      nixpkgs-zen,
      disko,
      home-manager,
      lanzaboote,
      ...
    }:
    let
      bladerunner = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          lanzaboote.nixosModules.lanzaboote
          ./hosts/bladerunner
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.users.freyaax400 = import ./hosts/bladerunner/home.nix;
          }
        ];
      };
      zenPkgs = import nixpkgs-zen {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      target = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          zenKernel = zenPkgs.linux_zen;
        };
        modules = [
          disko.nixosModules.disko
          (import ./disko.nix { })
          ./hardware-configuration.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.freyaax400 = import ./home.nix;
          }
        ];
      };

      swapped = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          (import ./disko.nix {
            big = "/dev/nvme1n1";
            small = "/dev/nvme0n1";
          })
        ];
      };
    in
    {
      nixosConfigurations.MoLK = target;
      nixosConfigurations.BladeRunner = bladerunner;
      nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit target swapped; };
        modules = [ ./installer.nix ];
      };
    };
}
