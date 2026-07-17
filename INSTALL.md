# Fresh machine install

Full environment from zero. Time budget: ~15 min of typing, ~15 min of downloads.

Two starting points:
- **A. Windows machine (WSL)** — e.g. a customer's cloud PC. Start at §1.
- **B. Existing Linux box** — skip to §2.

---

## 1. Windows → WSL (skip on native Linux)

> Needs local admin once, for WSL itself. On locked-down customer machines,
> have their IT run just this step.

In **admin** PowerShell:

```powershell
wsl --install -d Ubuntu-26.04
```

Reboot if asked, launch Ubuntu from the Start menu, create your unix user.

**Mirrored networking** (recommended — makes `localhost` work in BOTH
directions between Windows and WSL; NAT's port forwarding breaks regularly):

```powershell
# plain PowerShell, as your user:
Set-Content "$env:USERPROFILE\.wslconfig" "[wsl2]`nnetworkingMode=mirrored"
wsl --shutdown    # then reopen the terminal
```

## 2. Nix

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# open a new shell, then:
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

**Trusted user** — required by devenv/cachix (note: this is root-equivalent
on the machine; standard for a personal dev box, don't do it on shared servers):

```sh
echo "trusted-users = root $USER" | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon
```

## 3. This repo

```sh
git clone https://github.com/bjorkbjork/dotfiles.git ~/dotfiles
nix run home-manager -- switch -b backup --flake ~/dotfiles#francois
```

- `-b backup` moves the distro's stock `.bashrc`/`.profile` aside instead of failing.
- Different unix username? Edit `home.username`/`home.homeDirectory` in
  `home.nix` and the `homeConfigurations."<name>"` key in `flake.nix` first.
- Flake gotcha for later edits: **new files must be `git add`ed** before
  `home-manager switch` can see them.

Login shell:

```sh
echo "$HOME/.nix-profile/bin/zsh" | sudo tee -a /etc/shells
chsh -s "$HOME/.nix-profile/bin/zsh"
```

Open a new terminal: zsh + λ prompt + albafetch = success.

## 4. Keyring (headless/WSL only)

Backs `secretspec` in devenv projects. Machines with a real desktop login
unlock via PAM automatically and skip this. Note: blank-password keyring =
secrets unencrypted at the Linux FS layer — acceptable when the disk is
BitLocker/FDE-encrypted underneath.

```sh
systemctl --user stop gnome-keyring
printf '[keyring]\ndisplay-name=Default keyring\nctime=0\nmtime=0\nlock-on-idle=false\nlock-after=false\n' \
  > ~/.local/share/keyrings/Default_keyring.keyring
printf 'Default_keyring' > ~/.local/share/keyrings/default
chmod 600 ~/.local/share/keyrings/Default_keyring.keyring
systemctl --user start gnome-keyring
```

## 5. Identity & access

```sh
gh auth login                      # GitHub (browser flow)
ssh-keygen -t ed25519              # fresh key per machine; add to GitHub if needed
```

## 6. Windows Terminal font (WSL only)

The terminal renders with Windows fonts, so 3270 Nerd Font Mono must be
installed Windows-side (per-user, no admin). From WSL, after §3:

```sh
WINTMP=$(powershell.exe -NoProfile -Command '$env:TEMP' | tr -d '\r')
cp -L ~/.nix-profile/share/fonts/truetype/NerdFonts/3270/3270NerdFontMono-*.ttf "$(wslpath "$WINTMP")/"
powershell.exe -NoProfile -Command '
$dst = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
Get-ChildItem $env:TEMP -Filter "3270NerdFontMono-*.ttf" | ForEach-Object {
  Copy-Item $_.FullName $dst -Force
  $name = [IO.Path]::GetFileNameWithoutExtension($_.Name) -replace "NerdFontMono-", " Nerd Font Mono "
  New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" `
    -Name ($name + " (TrueType)") -Value (Join-Path $dst $_.Name) -PropertyType String -Force | Out-Null
}'
```

Then Windows Terminal → `Ctrl+,` → profile → Appearance → Font face →
**3270 Nerd Font Mono** (restart the terminal if it's not listed).

## 7. Project setup (Atlastix monorepo)

```sh
git clone https://github.com/<org>/atlastix-saas-api-services.git ~/Atlastix/atlastix-saas-api-services
cd ~/Atlastix/atlastix-saas-api-services
direnv allow        # builds the devenv shell; prompts for secrets (→ keyring)
devenv up           # starts postgres/keycloak/kafka/temporal/...
```

**Local TLS trust** (the stack serves HTTPS via a per-machine mkcert CA).
Optional but recommended: pin one CA for all devenv profiles first — create
`devenv.local.nix` (gitignored) in the repo root:

```nix
{ lib, ... }:
{
  env.CAROOT = lib.mkForce "/home/<user>/.local/share/devenv-mkcert";
  env.NODE_EXTRA_CA_CERTS =
    lib.mkForce "/home/<user>/.local/share/devenv-mkcert/rootCA.pem";
  # Python trusts the system bundle (add the CA to it below):
  env.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  env.REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
}
```

After the first `devenv up` generated the CA, trust it everywhere:

```sh
# Linux system bundle (backend services):
sudo cp ~/.local/share/devenv-mkcert/rootCA.pem /usr/local/share/ca-certificates/devenv-shared.crt
sudo update-ca-certificates

# Windows user store (browsers) — WSL only:
WINTMP=$(powershell.exe -NoProfile -Command '$env:TEMP' | tr -d '\r')
cp ~/.local/share/devenv-mkcert/rootCA.pem "$(wslpath "$WINTMP")/devenv-rootCA.pem"
powershell.exe -NoProfile -Command 'Import-Certificate -FilePath (Join-Path $env:TEMP "devenv-rootCA.pem") -CertStoreLocation Cert:\CurrentUser\Root'
```

Firefox additionally needs `about:config` → `security.enterprise_roots.enabled`
→ `true` (it ignores the Windows store otherwise), then a full restart.

Local login: `user1@example.com` / `password123` (bootstrap admin — see
`devenv/shared/configs/keycloak.yaml`). The social-login buttons don't work
locally (no brokered IdPs in the dev realm — see `docs/msp/plans/PLAN_018`).

## 8. Sanity checklist

| Check | Expect |
|---|---|
| new terminal | zsh, λ prompt, albafetch with nixos logo |
| `hms` | rebuilds cleanly |
| `git st` in a repo | delta pager, aliases work |
| `nvim` | plugins present, LSPs attach |
| `md2pdf README.md -o /tmp/x.pdf` | PDF appears |
| `secret-tool store/lookup` (§4 machines) | round-trips |
| `k9s` | starts (needs a kubeconfig to be useful) |
| browser → local stack | padlock, login works |
