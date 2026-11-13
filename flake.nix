{
  description = "MoLK";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-zen.url = "github:NixOS/nixpkgs/7929f16806e06c78a81d297e04cc8d03551f59fc"; 
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-zen, disko, home-manager, ... }:
    let
      zenPkgs = import nixpkgs-zen {
  system = "x86_64-linux";
  config.allowUnfree = true;
};
      target = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { zenKernel = zenPkgs.linux_zen; };
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

      # same layout with the two drives' roles swapped, picked at install time by size
      swapped = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          (import ./disko.nix { big = "/dev/nvme1n1"; small = "/dev/nvme0n1"; })
        ];
      };
    in
    {
      nixosConfigurations.MoLK = target;
      nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit target swapped; };
        modules = [ ./installer.nix ];
      };
    };
}
