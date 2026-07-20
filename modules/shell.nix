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

  # Full lambda prompt (faithful to the oh-my-bash setup on the old laptop):
  #   ╭─ 👨🏼‍💻 francois at 💻 host in 📂 ~/…/repo on ( branch {2} •11 ⌀45 ✗)
  #   ╰λ
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "[╭─](dim white) 👨🏼‍💻 $username[at](dim white) 💻 $hostname[in](dim white) 📂 $directory$git_branch$git_status$cmd_duration$line_break[╰λ](bold yellow)$character ";

      username = {
        show_always = true;
        format = "[$user](bold red) ";
      };
      hostname = {
        ssh_only = false;
        format = "[$hostname](bold #228b22) "; # forest green
      };
      directory = {
        style = "bold #39ff14"; # neon green
        truncation_length = 3;
        truncation_symbol = "…/";
        truncate_to_repo = false;
        format = "[$path]($style)[$read_only](red) ";
      };
      git_branch = {
        # Self-closing parens — git_status renders nothing on a clean repo,
        # so it can't be trusted to close a paren opened here.
        format = "[on](dim white) [\\( $branch\\)](bold purple) ";
      };
      # {stashes} +staged •modified -deleted ⌀untracked ⇡⇣ — ✗ shows whenever
      # the module renders at all, i.e. whenever there is anything to report.
      git_status = {
        format = "$stashed$staged$modified$deleted$untracked$ahead_behind$conflicted[ ✗](bold red) ";
        stashed = "[ \\{$count\\}](dim white)";
        staged = "[ +$count](bold #00e676)"; # bright green
        modified = "[ •$count](bold #ff8c00)"; # orange — unstaged
        deleted = "[ -$count](#8b0000)"; # dark red
        untracked = "[ ⌀$count](#5fafff)";
        ahead = "[ ⇡$count](green)";
        behind = "[ ⇣$count](red)";
        diverged = "[ ⇡$ahead_count⇣$behind_count](yellow)";
        conflicted = "[ =$count](bold red)";
      };
      cmd_duration = {
        min_time = 2000;
        format = "took [$duration](bold yellow) ";
      };
      character = {
        success_symbol = ""; # λ is part of format; no extra char
        error_symbol = "[✘](bold red)";
      };

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
