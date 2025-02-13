# Edit this configuration file to define what should be installed on
# Funnily enough because I had two GPUs I had to do all of this at first
# in just tty. I hated it. It'll be fixed eventually I guess.

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./boot.nix
    ];

  # Defaults?
  networking.hostName = "nixy"; # Define your hostname.
  networking.networkmanager.enable = true;
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # NVIDIA Drivers
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # GNOME
  # services.xserver.enable = true;
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # KDE
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  
  # Optional Desktop Environments for testing
  # services.xserver.desktopManager.xfce.enable = true;

  # PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.emi = {
    isNormalUser = true;
    description = "Emi Madison Jade-Steele";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  users.groups.libvirtd.members = [ "emi" ];

  # Packages
  nixpkgs.config.allowUnfree = true;

  # Mullvad VPN
  services.mullvad-vpn.enable = true;

  # Global system package
  environment.systemPackages = with pkgs; [
    wineWowPackages.stable

    kdePackages.discover

    ubuntu-sans
    noto-fonts
    noto-fonts-extra
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.ubuntu-sans

    wl-clipboard #Fixes clipboard in various apps
    sqlite
    kdePackages.partitionmanager

    virt-manager
    looking-glass-client
    swtpm
    pciutils
    virtiofsd
  ];


  # Extra System stuff
  programs.kdeconnect.enable = true;
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  services.flatpak.enable = true;
  
  # Virtualisation
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.ovmf.enable = true;
  virtualisation.waydroid.enable = true;

  # Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Nix features and version
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.11";
}
