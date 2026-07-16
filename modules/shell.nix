{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    defaultKeymap = "emacs"; # readline-style keys, same as bash

    history = {
      size = 100000;
      save = 100000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    shellAliases = {
      g = "git";
      lg = "lazygit";
      v = "nvim";
      ".." = "cd ..";
      "..." = "cd ../..";
      # Rebuild the home environment from this repo.
      hms = "home-manager switch --flake ~/dotfiles";
    };
  };

  # Keep bash usable too — same session vars, and hand off to zsh-aware tools.
  programs.bash.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      # Trim latency: skip slow modules we don't need in the prompt.
      package.disabled = true;
    };
  };

  # Ctrl-R fuzzy history, Ctrl-T file picker, Alt-C cd.
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidget.command = "fd --type f --hidden --exclude .git";
    changeDirWidget.command = "fd --type d --hidden --exclude .git";
  };

  # Smarter cd: `z proj` jumps to frecent dirs.
  programs.zoxide.enable = true;
}
