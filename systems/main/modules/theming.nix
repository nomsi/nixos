{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    yaru-theme
    gnome-software
    ubuntu-themes
    gnome-tweaks

    ubuntu-sans
  ];
}