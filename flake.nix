{
  description = "Freyix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-zen.url = "github:NixOS/nixpkgs/7929f16806e06c78a81d297e04cc8d03551f59fc";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
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
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-zen,
      disko,
      home-manager,
      lanzaboote,
      sops-nix,
      nix-vscode-extensions,
      ...
    }:
    let
      # One NixOS host: hosts/<name>/default.nix + hosts/<name>/home.nix (home-manager).
      mkHost =
        {
          name,
          modules ? [ ],
          specialArgs ? { },
        }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./hosts/${name}
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "bak";
                users.freyaax400 = import ./hosts/${name}/home.nix;
              };
              nixpkgs.overlays = [ nix-vscode-extensions.overlays.default ];
            }
          ]
          ++ modules;
        };

      zenPkgs = import nixpkgs-zen {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      target = mkHost {
        name = "molk";
        specialArgs.zenKernel = zenPkgs.linux_zen;
        modules = [ disko.nixosModules.disko ];
      };

      # MoLK's disk layout with the two NVMe drives swapped, for the installer ISO.
      swapped = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          (import ./hosts/molk/disko.nix {
            big = "/dev/nvme1n1";
            small = "/dev/nvme0n1";
          })
        ];
      };
    in
    {
      nixosConfigurations = {
        MoLK = target;
        BladeRunner = mkHost {
          name = "bladerunner";
          modules = [
            sops-nix.nixosModules.sops
            lanzaboote.nixosModules.lanzaboote
          ];
        };
        installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit target swapped; };
          modules = [ ./installer.nix ];
        };
      };
    };
}
