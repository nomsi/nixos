{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    nix-output-monitor
    nil
    vscode
  ];
};