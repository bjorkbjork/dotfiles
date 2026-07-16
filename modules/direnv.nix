{ ... }:

{
  # Per-project environments: drop a flake.nix + `use flake` in .envrc and the
  # dev shell activates on cd. nix-direnv caches the shell so it's instant.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # Shell integrations (zsh/bash) are enabled automatically.
  };
}
