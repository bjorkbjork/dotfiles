{ pkgs, ... }:

{
  # Note: on WSL the terminal font is rendered by Windows Terminal, so nerd
  # fonts must also be installed Windows-side. This covers native Linux boxes.
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerd-fonts._3270
    noto-fonts # mainfont for pandoc/typst PDFs
  ];
}
