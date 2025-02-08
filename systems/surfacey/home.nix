{ config, pkgs, ... }:

{
  imports = [
    ./modules/bash.nix
    ./modules/code.nix
    ./modules/zip.nix
  ];

  home.username = "emi";
  home.homeDirectory = "/home/emi";

  home.packages = with pkgs; [
    winetricks
    spotify
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Emi Jade";
    userEmail = "me@emi.lgbt";
  };

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}