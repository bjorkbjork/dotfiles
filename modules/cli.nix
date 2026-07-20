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

    # beads (bd) — issue tracking used across the Atlastix monorepo.
    inputs.beads.packages.${pkgs.system}.default
  ];

  xdg.configFile."albafetch.conf".source = ../files/albafetch.conf;

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

      # Clipboard: tmux's default OSC 52 sync (set-clipboard external) already
      # lands copies on the Windows clipboard — Windows Terminal supports it.
      # Do NOT set copy-command/clip.exe pipes on top: every copy would be
      # written twice.

      # vim muscle memory: v begins selection (tmux default is Space; v is
      # rectangle-toggle — pressing v, moving, then y copies NOTHING).
      bind -T copy-mode-vi v send -X begin-selection

      # Prefix+Y: entire visible pane -> Windows clipboard. Works over any
      # mouse-capturing TUI (devenv, k9s) because it reads the pane, not the
      # mouse. TUIs run on the alternate screen, so this captures what is
      # currently displayed.
      bind Y run-shell "tmux capture-pane -p -S -1000 | clip.exe"

      # Prefix+m: toggle tmux mouse capture. Off = Windows Terminal handles
      # drag/Ctrl+C natively on the visible screen; on = tmux scroll/copy-mode.
      bind m set -g mouse \; display "mouse: #{?mouse,on,off}"
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "clip.exe"
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "clip.exe"

      # devenv's TUI grabs the mouse but implements no selection/copy (unlike
      # claude/nvim, which do their own OSC 52 copy). Forward mouse to apps
      # that grab it EXCEPT devenv — there, tmux takes the drag: highlight,
      # release, and it's on the Windows clipboard. Wheel still reaches the
      # TUI for native log scrolling.
      bind -n MouseDrag1Pane if -F '#{||:#{pane_in_mode},#{&&:#{mouse_any_flag},#{!=:#{pane_current_command},devenv}}}' { send-keys -M } { copy-mode -M }
    '';
  };

  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };
}
