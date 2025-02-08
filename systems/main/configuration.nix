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
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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

  # Packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
  ];

  # Extra System stuff
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  services.flatpak.enable = true;
  virtualisation = {
    libvirtd = {
      enable = true;
      qemuOvmf = true;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.11";
}
