{ pkgs, ... }:

{
  # WSL-specific glue. Harmless on native Linux, but only useful under WSL.

  # Minimal wslview: hand URLs/files to Windows to open with the default app.
  # (wslu, the usual provider, was discontinued and removed from nixpkgs.)
  home.packages = [
    (pkgs.writeShellScriptBin "wslview" ''
      exec /mnt/c/Windows/System32/rundll32.exe url.dll,FileProtocolHandler "$1"
    '')
  ];

  # CLIs that open auth/login pages (az, gh, gcloud, …) honor $BROWSER.
  # Without this they call gio/xdg-open, which has nothing to talk to in WSL:
  # "Operation not supported".
  home.sessionVariables.BROWSER = "wslview";
}
