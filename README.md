# dotfiles

Portable development environment via [Nix Home Manager](https://nix-community.github.io/home-manager/).
One repo → full shell, git, tmux, nvim, and CLI toolbox on any Linux box (incl. WSL).

## Bootstrap a new machine

```sh
# 1. Install Nix (multi-user) if not present
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Enable flakes
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# 3. Clone and switch
git clone https://github.com/bjorkbjork/dotfiles.git ~/dotfiles
nix run home-manager -- switch --flake ~/dotfiles#francois

# 4. Make zsh the login shell
echo "$HOME/.nix-profile/bin/zsh" | sudo tee -a /etc/shells
chsh -s "$HOME/.nix-profile/bin/zsh"

# 5. Headless/WSL only: seed a blank-password keyring (one-time; a machine
#    with a real login session unlocks via PAM instead and can skip this)
systemctl --user stop gnome-keyring
printf '[keyring]\ndisplay-name=Default keyring\nctime=0\nmtime=0\nlock-on-idle=false\nlock-after=false\n' \
  > ~/.local/share/keyrings/Default_keyring.keyring
printf 'Default_keyring' > ~/.local/share/keyrings/default
chmod 600 ~/.local/share/keyrings/Default_keyring.keyring
systemctl --user start gnome-keyring
```

Open a new terminal. Done — nvim config auto-clones to `~/.config/nvim` on first switch.

> Different username on a client machine? Add a `homeConfigurations."<user>"`
> entry in `flake.nix` (and matching `home.username`/`home.homeDirectory`),
> or just edit the existing one.

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
