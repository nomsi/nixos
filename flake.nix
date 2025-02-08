{
  description = "EMJS NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = inputs@{ nixpkgs, home-manager, nixos-hardware, ... }: {
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
            system.extraSystemBuilderCmds = ''
              ln -s ${self} $out/flake
              ln -s ${self.nixosConfigurations.papyrus.config.boot.kernelPackages.kernel.dev} $out/kernel-dev
            '';
          }
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
