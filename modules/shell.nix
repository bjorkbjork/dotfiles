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

  # Full lambda prompt, faithful to the oh-my-bash lambda theme source
  # (OMB color names are ANSI slots: bold_brown=red, bold_teal=teal/cyan,
  # bold_olive=yellow — the old Konsole palette did the rest):
  #   ╭─ 👨🏼‍💻 francois at 💻 host in 📂 ~/…/repo on (🌿 branch {2} •11 ⌀45 ✗)
  #   ╰λ
  # Status lives INSIDE the parens; custom modules provide the always-closing
  # paren and the ✓/✗ clean/dirty flag, which stock git_status cannot do.
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "[╭─](white) 👨🏼‍💻 $username[at](white) 💻 $hostname[in](white) 📂 $directory$git_branch$git_status\${custom.git_dirty}\${custom.git_clean}\${custom.git_close}$cmd_duration$line_break[╰λ](bold white)$character ";

      # The monorepo is big; the 500ms default silently drops status counters.
      command_timeout = 2000;

      username = {
        show_always = true;
        format = "[$user](bold red) "; # OMB bold_brown
      };
      hostname = {
        ssh_only = false;
        format = "[$hostname](bold #4ec9b0) "; # OMB bold_teal as it looked on Monalyte
      };
      directory = {
        style = "bold green";
        truncation_length = 3;
        truncation_symbol = "…/";
        truncate_to_repo = false;
        format = "[$path]($style)[$read_only](red) ";
      };
      git_branch = {
        format = "[on](white) [\\(](white)🌿 [$branch](white)";
      };
      # (🌿 branch {stash} +staged •unstaged -deleted ⌀untracked ↑↓ ✗|✓)
      git_status = {
        format = "$stashed$staged$modified$deleted$untracked$ahead_behind$conflicted";
        stashed = "[ \\{$count\\}](white)";
        staged = "[ +$count](bold green)";
        modified = "[ •$count](bold yellow)"; # OMB bold_olive
        deleted = "[ -$count](red)";
        untracked = "[ ⌀$count](white)";
        ahead = "[ ↑$count](bold green)";
        behind = "[ ↓$count](red)"; # OMB brown
        diverged = "[ ↑$ahead_count↓$behind_count](yellow)";
        conflicted = "[ =$count](bold red)";
      };
      custom.git_dirty = {
        when = "test -n \"$(git status --porcelain 2>/dev/null)\"";
        require_repo = true;
        command = "";
        format = "[ ✗](red)";
      };
      custom.git_clean = {
        when = "test -z \"$(git status --porcelain 2>/dev/null)\"";
        require_repo = true;
        command = "";
        format = "[ ✓](bold green)";
      };
      custom.git_close = {
        when = "true";
        require_repo = true;
        command = "";
        format = "[\\)](white) ";
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
