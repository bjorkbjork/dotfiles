{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      # Case-insensitive tab completion (glow r<Tab> → README.md)
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # Shell greeting, as tradition demands (was line 1 of the old .bashrc).
      albafetch
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    defaultKeymap = "emacs"; # readline-style keys, same as bash

    history = {
      size = 100000;
      save = 100000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

  };

  # Shared by bash and zsh.
  home.shellAliases = {
    g = "git";
    lg = "lazygit";
    v = "nvim";
    ".." = "cd ..";
    "..." = "cd ../..";
    # Rebuild the home environment from this repo.
    hms = "home-manager switch --flake ~/dotfiles";

    # alembic / project runners (ported from Arch, pdm → uv)
    alr = "uv run alembic revision --autogenerate -m";
    alrm = "uv run alembic revision -m";
    alu = "uv run alembic upgrade head";
    ust = "uv run start";
    mcpst = "uv run python -m mcp_servers.http_server";
    nst = "npm run start";
    md2pdf = "pandoc -d defaults";
  };

  # Keep bash usable too — same session vars, and hand off to zsh-aware tools.
  programs.bash.enable = true;

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
