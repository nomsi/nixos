{ config, pkgs, ... }:

{
  # TODO please change the username & home directory to your own
  home.username = "emi";
  home.homeDirectory = "/home/emi";

  home.packages = with pkgs; [
    neofetch
    hyfetch

    # zips!
    zip
    xz
    unzip
    p7zip
    ripgrep
    eza
    fzf

    # networking tools
    iperf3
    dnsutils  # `dig` + `nslookup`
    dnsmasq

    nix-output-monitor
    nil

    btop
    iotop
    iftop
    bat

    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils
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