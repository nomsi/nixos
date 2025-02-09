{ config, pkgs, ... }:
{

  home.packages = with pkgs; [
    neofetch
    hyfetch
    ripgrep
    eza
    fzf
    bat
    vim
    curl

    tailscale
  ];

  programs.starship = {
    enable = true;
    settings = pkgs.lib.importTOML ./configs/starship.toml;
  };


  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      eval "$(starship init bash)"
    '';
    shellAliases = {
      cat = "bat";
    };
  };
}