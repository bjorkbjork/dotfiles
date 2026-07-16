{ pkgs, lib, config, inputs, ... }:

{
  # Editor, LSPs, formatters, and runtime deps from the nvim-config flake.
  home.packages = [
    inputs.nvim-config.packages.${pkgs.system}.default
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # The Lua config lives in the same repo, cloned as a *live* checkout rather
  # than a read-only store symlink — lazy.nvim needs to write lazy-lock.json,
  # and this way the config can be edited/pushed without a home-manager rebuild.
  home.activation.cloneNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${config.xdg.configHome}/nvim" ]; then
      run ${pkgs.git}/bin/git clone https://github.com/bjorkbjork/nvim-config.git \
        "${config.xdg.configHome}/nvim"
    fi
  '';
}
