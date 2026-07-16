{ pkgs, lib, ... }:

{
  # Secret Service (org.freedesktop.secrets) for headless/WSL machines —
  # backs secretspec's keyring provider in devenv projects. Requires a
  # systemd user session with DBus (WSL2 with systemd=true has both).
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  # secret-tool: CLI to store/lookup secrets in the keyring.
  home.packages = [ pkgs.libsecret ];

  # Upstream unit binds to graphical-session-pre.target, which never starts
  # on headless WSL — bind to the ordinary user session instead.
  systemd.user.services.gnome-keyring = {
    Unit.PartOf = lib.mkForce [ ];
    Install.WantedBy = lib.mkForce [ "default.target" ];
  };
}
