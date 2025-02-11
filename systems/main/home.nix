{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/bash.nix
    ./modules/code.nix
    ./modules/zip.nix
    inputs.spicetify-nix.homeManagerModules.default
  ];

  home.username = "emi";
  home.homeDirectory = "/home/emi";

  home.packages = with pkgs; [
    winetricks
    libreoffice
    qbittorrent
    vlc
    spotify-player
    browsh
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Emi Jade";
    userEmail = "me@emi.lgbt";
  };

  programs.spicetify =
  let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in
  {
    enable = true;
    theme = spicePkgs.themes.catppuccin;
  };

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}