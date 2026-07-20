{ pkgs, ... }:

{
  # WSL-specific glue. Harmless on native Linux, but only useful under WSL.

  home.packages = with pkgs; [
    wslu # wslview: opens URLs/files via Windows (default browser, etc.)
  ];

  # CLIs that open auth/login pages (az, gh, gcloud, …) honor $BROWSER.
  # Without this they call gio/xdg-open, which has nothing to talk to in WSL:
  # "Operation not supported".
  home.sessionVariables.BROWSER = "wslview";
}
