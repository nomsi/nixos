{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    yaru-theme
    gnome-software
    ubuntu-sans
    ubuntu-themes
    gnome-tweaks
  ];
};