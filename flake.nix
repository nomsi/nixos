{
  description = "EMJS NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # Home Manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NixOS Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Spicetify
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, 
                     nixos-hardware, spicetify-nix, ... }: {
    nixosConfigurations = {
      nixy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./systems/main/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.emi = import ./systems/main/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
      surfacey = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./systems/surfacey/configuration.nix
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          {
            nix.registry.nixpkgs.flake = nixpkgs;
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.emi = import ./systems/surfacey/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
  };
}
