{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
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

}