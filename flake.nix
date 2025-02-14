{
  description = "EMJS NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NixOS Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Spicetify
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Rust
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NVChad4Nix
    nvchad4nix = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      spicetify-nix,
      rust-overlay,
      nvchad4nix,
      ...
    }:
    {
      nixosConfigurations = {
        nixy = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./systems/main/configuration.nix
            (
              { pkgs, ... }:
              {
                nixpkgs.overlays = [ rust-overlay.overlays.default ];
                environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
              }
            )
            {
              nixpkgs = {
                overlays = [
                  (final: prev: {
                    nvchad = inputs.nvchad4nix.packages."${nixpkgs.pkgs.system}".nvchad;
                  })
                ];
              };
            }
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
            (
              { pkgs, ... }:
              {
                nixpkgs.overlays = [ rust-overlay.overlays.default ];
                environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
              }
            )
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
