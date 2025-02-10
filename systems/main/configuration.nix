# Edit this configuration file to define what should be installed on
# Funnily enough because I had two GPUs I had to do all of this at first
# in just tty. I hated it. It'll be fixed eventually I guess.

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./boot.nix
      ./nordvpn.nix
    ];

  # NordVPN Test
  nixpkgs.config.packageOverrides = pkgs: {
    nordvpn = pkgs.callPackage ({ pkgs, lib, gcc, autoPatchelfHook, ... }:
      let
        patchedPkgs = pkgs.appendOverlays [
          (final: prev: {
            # Nordvpn uses a patched openvpn in order to perform xor obfuscation
            # See https://github.com/NordSecurity/nordvpn-linux/blob/e614303aaaf1a64fde5bb1b4de1a7863b22428c4/ci/openvpn/check_dependencies.sh
            openvpn = prev.openvpn.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [
                (prev.fetchpatch {
                  url =
                    "https://github.com/Tunnelblick/Tunnelblick/raw/master/third_party/sources/openvpn/openvpn-${old.version}/patches/02-tunnelblick-openvpn_xorpatch-a.diff";
                  hash = "sha256-b9NiWETc0g2a7FNwrLaNrWx7gfCql7VTbewFu3QluFk=";
                })
                (prev.fetchpatch {
                  url =
                    "https://github.com/Tunnelblick/Tunnelblick/raw/master/third_party/sources/openvpn/openvpn-${old.version}/patches/03-tunnelblick-openvpn_xorpatch-b.diff";
                  hash = "sha256-X/SshB/8ItLFBx6TPhjBwyA97ra0iM2KgsGqGIy2s9I=";
                })
                (prev.fetchpatch {
                  url =
                    "https://github.com/Tunnelblick/Tunnelblick/raw/master/third_party/sources/openvpn/openvpn-${old.version}/patches/04-tunnelblick-openvpn_xorpatch-c.diff";
                  hash = "sha256-fw0CxJGIFEydIVRVouTlD1n275eQcbejUdhrU1JAx7g=";
                })
                (prev.fetchpatch {
                  url =
                    "https://github.com/Tunnelblick/Tunnelblick/raw/master/third_party/sources/openvpn/openvpn-${old.version}/patches/05-tunnelblick-openvpn_xorpatch-d.diff";
                  hash = "sha256-NLRtoRVz+4hQcElyz4elCAv9l1vp4Yb3/VJef+L/FZo=";
                })
                (prev.fetchpatch {
                  url =
                    "https://github.com/Tunnelblick/Tunnelblick/raw/master/third_party/sources/openvpn/openvpn-${old.version}/patches/06-tunnelblick-openvpn_xorpatch-e.diff";
                  hash = "sha256-mybdjCIT9b6ukbGWYvbr74fKtcncCtTvS5xSVf92T6Y=";
                })
              ];
            });
          })
        ];
        nordvpn = pkgs.buildGoModule rec {
          pname = "nordvpn";
          version = "3.19.0";

          #src = ./.;
          src = pkgs.fetchFromGitHub {
            owner = "NordSecurity";
            repo = "nordvpn-linux";
            rev = "e614303aaaf1a64fde5bb1b4de1a7863b22428c4";
            sha256 = "sha256-uIzG9QIVwax0Cop2VuDzy033efEBudFnGNj7osT/x2g";
          };

          nativeBuildInputs = with pkgs; [ pkg-config gcc ];

          buildInputs = with pkgs; [ libxml2 gcc ];

          vendorHash = "sha256-h5G5J/Sw0277pDzVXT6b3BX0KUbtyN8ujITfYp5PmgE";

          ldflags = [
            "-X main.Version=${version}"
            "-X main.Environment=dev"
            "-X main.Salt=development"
            "-X main.Hash=${src.rev}"
          ];

          buildPhase = ''
            runHook preBuild
            echo "Building nordvpn CLI..."
            export LDFLAGS="${builtins.concatStringsSep " " ldflags}"
            go build -ldflags "$LDFLAGS" -o bin/nordvpn ./cmd/cli

            echo "Building nordvpn user..."
            go build -ldflags "$LDFLAGS" -o bin/norduserd ./cmd/norduser

            # Fix missing include in a library preventing compilation
            chmod +w vendor/github.com/jbowtie/gokogiri/xpath/
            sed -i '6i#include <stdlib.h>' vendor/github.com/jbowtie/gokogiri/xpath/expression.go

            echo "Building nordvpn daemon..."
            go build -ldflags "$LDFLAGS" -o bin/nordvpnd ./cmd/daemon
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/lib/nordvpn/
            mv bin/norduserd $out/lib/nordvpn/
            ln -s ${patchedPkgs.openvpn}/bin/openvpn $out/lib/nordvpn/openvpn
            ln -s ${pkgs.wireguard-tools}/bin/wg $out/lib/nordvpn/wg

            # Nordvpn needs icons for the system tray
            mkdir -p $out/share/icons/hicolor/scalable/apps
            nordvpn_asset_prefix="nordvpn-" # hardcoded image prefix
            cp assets/icon.svg $out/share/icons/hicolor/scalable/apps/nordvpn.svg # Does not follow convention
            for file in assets/*.svg; do
              cp "$file" "$out/share/icons/hicolor/scalable/apps/''${nordvpn_asset_prefix}$(basename "$file")"
            done

            mkdir -p $out/bin
            cp bin/* $out/bin

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "NordVPN CLI and daemon application for Linux";
            homepage = "https://github.com/nordsecurity/nordvpn-linux";
            mainProgram = "nordvpn";
            license = licenses.gpl3;
            platforms = platforms.linux;
          };
        };
      in pkgs.buildFHSEnv {
        name = "nordvpnd";
        targetPkgs = with pkgs;
          pkgs: [
            nordvpn
            sysctl
            iptables
            iproute2
            procps
            cacert
            libxml2
            libidn2
            zlib
            wireguard-tools
            patchedPkgs.openvpn
            e2fsprogs # for chattr
          ];

        extraInstallCommands = ''
          mkdir -p $out/bin/
          printf "#!${pkgs.bash}/bin/bash\n${nordvpn}/bin/nordvpn \"\$@\"" > $out/bin/nordvpn
          chmod +x $out/bin/nordvpn
        '';

        runScript = ''
          ${nordvpn}/bin/nordvpnd
        '';
      }) { inherit lib; };
  };

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
    wineWowPackages.stable

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

    virt-manager
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

  # Systemd Services
  systemd = {
    services.nordvpn = {
      description = "NordVPN daemon.";
      serviceConfig = {
        ExecStart = "${pkgs.nordvpn}/bin/nordvpnd";
        ExecStartPre = ''
          ${pkgs.bash}/bin/bash -c '\
            mkdir -m 700 -p /var/lib/nordvpn; \
            if [ -z "$(ls -A /var/lib/nordvpn)" ]; then \
              cp -r ${pkgs.nordvpn}/var/lib/nordvpn/* /var/lib/nordvpn; \
            fi'
        '';
        NonBlocking = true;
        KillMode = "process";
        Restart = "on-failure";
        RestartSec = 5;
        RuntimeDirectory = "nordvpn";
        RuntimeDirectoryMode = "0750";
        Group = "nordvpn";
      };
      wantedBy = [ "multi-user.target" ];
      #after = [ "network-online.target" ];
      #wants = [ "network-online.target" ];
    };
    services.NetworkManager-wait-online.enable = lib.mkForce false;
  };
  
  # Virtualisation
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.ovmf.enable = true;

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
