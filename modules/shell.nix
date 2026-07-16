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
    pst = "uv run start";
    mcpst = "uv run python -m mcp_servers.http_server";
    nst = "npm run start";
    md2pdf = "pandoc -d defaults";
  };

  # Keep bash usable too — same session vars, and hand off to zsh-aware tools.
  programs.bash.enable = true;

  # Two-line lambda prompt (nod to oh-my-bash lambda / lambda-mod):
  #   λ francois@host ~/dotfiles (main) [⇡1 +2 !1 ?3] took 4s
  #   ›
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "[λ](bold yellow) $username$hostname$directory$git_branch$git_status$cmd_duration$line_break$character";

      username = {
        show_always = true;
        format = "[$user](bold blue)";
      };
      hostname = {
        ssh_only = false;
        format = "[@$hostname](blue) ";
      };
      directory = {
        style = "bold cyan";
        truncation_length = 6;
        truncate_to_repo = false;
        format = "[$path]($style)[$read_only](red) ";
      };
      git_branch = {
        format = "[\\($branch\\)](bold purple) ";
      };
      # [⇡ahead ⇣behind =conflicted ✘deleted $stashed +staged !modified ?untracked]
      git_status = {
        format = "([\\[$ahead_behind$conflicted$deleted$stashed$staged$modified$untracked\\]](dim white) )";
        ahead = "[⇡$count ](green)";
        behind = "[⇣$count ](red)";
        diverged = "[⇡$ahead_count⇣$behind_count ](yellow)";
        conflicted = "[=$count ](red)";
        deleted = "[✘$count ](red)";
        stashed = "[\\$$count ](white)";
        staged = "[+$count ](green)";
        modified = "[!$count ](yellow)";
        untracked = "[?$count ](blue)";
      };
      cmd_duration = {
        min_time = 2000;
        format = "took [$duration](bold yellow) ";
      };
      character = {
        success_symbol = "[›](bold green)";
        error_symbol = "[›](bold red)";
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
