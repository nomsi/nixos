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

    yaru-theme
    gnome-software
    ubuntu-themes
    gnome-tweaks

    ubuntu-sans
    noto-fonts
    noto-fonts-extra
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
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