{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./modules/bash.nix
    ./modules/code.nix
    ./modules/zip.nix
    inputs.spicetify-nix.homeManagerModules.default
    inputs.nvchad4nix.homeManagerModule
  ];

  home.username = "emi";
  home.homeDirectory = "/home/emi";

  home.packages = with pkgs; [
    ckb-next
    winetricks
    libreoffice
    qbittorrent
    vlc
    spotify-player
    browsh
    nerd-fonts.ubuntu-sans
    nerd-fonts.ubuntu-mono

    kdePackages.powerdevil
    kdePackages.kate
    kdePackages.spectacle
    kdePackages.poppler
    kdePackages.plasmatube
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Emi Jade";
    userEmail = "me@emi.lgbt";
  };

  programs.nvchad = {
    enable = true;
    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      docker-compose-language-service
      dockerfile-language-server-nodejs
      nixd
      rust-analyzer
      (python3.withPackages (
        ps: with ps; [
          python-lsp-server
          flake8
        ]
      ))
    ];
    hm-activation = true;
    backup = true;
  };

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
    };

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
