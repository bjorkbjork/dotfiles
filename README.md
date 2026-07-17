# dotfiles

Portable development environment via [Nix Home Manager](https://nix-community.github.io/home-manager/).
One repo → full shell, git, tmux, nvim, and CLI toolbox on any Linux box (incl. WSL).

## Bootstrap a new machine

**See [INSTALL.md](INSTALL.md)** — full walkthrough from a bare Windows
(WSL) or Linux box to a working environment, including the WSL-specific
steps (mirrored networking, keyring, fonts, local TLS trust).

The 30-second version for a Linux box that already has nix + flakes:

```sh
git clone https://github.com/bjorkbjork/dotfiles.git ~/dotfiles
nix run home-manager -- switch -b backup --flake ~/dotfiles#francois
```

## Daily use

| Task | Command |
|---|---|
| Apply config changes | `hms` (alias for `home-manager switch --flake ~/dotfiles`) |
| Update all inputs (nixpkgs, nvim, …) | `nix flake update ~/dotfiles && hms` |
| Roll back | `home-manager generations` → `<path>/activate` |
| Clean old generations | `home-manager expire-generations '-30 days' && nix store gc` |

## Layout

```
flake.nix          # inputs: nixpkgs, home-manager, nvim-config
home.nix           # entry point, imports modules/
modules/
  cli.nix          # rg, fd, jq, bat, eza, btop, tmux, …
  direnv.nix       # direnv + nix-direnv for per-project flakes
  git.nix          # identity, delta, aliases, gh, lazygit
  nvim.nix         # nvim env from the nvim-config flake input
  shell.nix        # zsh + starship + fzf + zoxide
```

The nvim **binaries** (LSPs, formatters) come from the
[nvim-config](https://github.com/bjorkbjork/nvim-config) flake; the **Lua
config** is a live git checkout at `~/.config/nvim` so `lazy-lock.json` stays
writable and config edits don't require a rebuild.
