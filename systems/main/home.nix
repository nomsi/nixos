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

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };


  programs.bash = {
    enable = true;
    enableCompletion = true;
    # set some aliases, feel free to add more or remove some
    shellAliases = {
      cat = "bat";
    };
  };
  home.stateVersion = "24.11";
  
  programs.home-manager.enable = true;
}