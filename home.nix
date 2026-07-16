{ ... }:

{
  imports = [
    ./modules/cli.nix
    ./modules/direnv.nix
    ./modules/git.nix
    ./modules/nvim.nix
    ./modules/shell.nix
  ];

  home.username = "francois";
  home.homeDirectory = "/home/francois";

  # Non-NixOS (Ubuntu/WSL): fixes PATH, XDG_DATA_DIRS, etc. so nix-installed
  # apps and completions are found by the system.
  targets.genericLinux.enable = true;

  # Let home-manager manage itself, so `home-manager switch` works after the
  # first bootstrap via `nix run`.
  programs.home-manager.enable = true;

  # Do not change after initial setup — controls state migration defaults.
  home.stateVersion = "26.05";
}
