{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    fd
    glow
    jq
    ripgrep
    unzip
    uv
    wget

    # AI coding agents — non-negotiable on any machine.
    claude-code
    opencode

    # Beloved fetch greeter (runs on shell start, see shell.nix).
    inputs.albafetch.packages.${pkgs.system}.default
  ];

  # cat with syntax highlighting; also used as man pager below.
  programs.bat.enable = true;

  # Modern ls. Provides ls/ll/la/lt aliases in zsh automatically.
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };

  programs.btop.enable = true;

  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 10;
    terminal = "tmux-256color";
    historyLimit = 50000;
    shell = "${pkgs.zsh}/bin/zsh";
    extraConfig = ''
      # True color passthrough for nvim.
      set -ga terminal-overrides ",*256col*:Tc"

      # Intuitive splits that keep the current path.
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Vim-style pane navigation.
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };

  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };
}
