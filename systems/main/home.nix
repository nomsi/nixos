{ config, pkgs, ... }:

{
  home.username = "emi";
  home.homeDirectory = "/home/emi";

  imports = [
    ./modules/bash.nix
    ./modules/code.nix
    ./modules/theming.nix
    ./modules/zip.nix
  ];
  
  home.packages = with pkgs; [
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