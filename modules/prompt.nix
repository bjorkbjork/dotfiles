{ ... }:

let
  # ── Prompt theme toggle ──────────────────────────────────────────────
  # "blue"   — clean two-line:  λ user@host ~/dir (branch) [+2 •1 ✗]  /  ›
  # "lambda" — OMB lambda homage: ╭─ 👨🏼‍💻 user at 💻 host in 📂 dir on ( branch)…  /  ╰λ
  theme = "blue";
  # ─────────────────────────────────────────────────────────────────────

  # Rich git-status counters shared by both themes:
  # {stash} +staged •modified -deleted ⌀untracked ⇡⇣ahead/behind =conflicts
  gitCounters = {
    stashed = "[ \\{$count\\}](white)";
    staged = "[ + $count](bold #00e676)"; # bright green
    modified = "[ • $count](bold #ff8c00)"; # orange — unstaged
    deleted = "[ - $count](#8b0000)"; # dark red
    untracked = "[ ⌀ $count](white)";
    ahead = "[ ⇡ $count](green)";
    behind = "[ ⇣ $count](red)";
    diverged = "[ ⇡ $ahead_count⇣ $behind_count](yellow)";
    conflicted = "[ =$count](bold red)";
  };

  common = {
    add_newline = true;
    # The monorepo is big; the 500ms default silently drops status counters.
    command_timeout = 2000;
    cmd_duration = {
      min_time = 2000;
      format = "took [$duration](bold yellow) ";
    };
    # Trim latency: skip slow modules we don't need in the prompt.
    package.disabled = true;
  };

  blue = common // {
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
    # Whole bracket group disappears on a clean repo; ✗ marks anything to report.
    git_status = gitCounters // {
      format = "([\\[$stashed$staged$modified$deleted$untracked$ahead_behind$conflicted[ ✗](bold red)\\]](dim white) )";
    };
    character = {
      success_symbol = "[›](bold green)";
      error_symbol = "[›](bold red)";
    };
  };

  lambda = common // {
    format = "[╭─](dim white) 👨🏼‍💻 $username[at](dim white) 💻 $hostname[in](dim white) 📂 $directory$git_branch$git_status$cmd_duration$line_break[╰λ](bold white)$character ";
    username = {
      show_always = true;
      format = "[$user](bold red) ";
    };
    hostname = {
      ssh_only = false;
      format = "[$hostname](bold #4ec9b0) "; # OMB bold_teal, as it rendered on Monalyte
    };
    directory = {
      style = "bold green"; # muted ANSI green
      truncation_length = 3;
      truncation_symbol = "…/";
      truncate_to_repo = false;
      format = "[$path]($style)[$read_only](red) ";
    };
    git_branch = {
      # Self-closing parens — git_status renders nothing on a clean repo,
      # so it can't be trusted to close a paren opened here.
      format = "[on](dim white) [  \\($branch\\)](bold purple) ";
    };
    # ✗ shows whenever the module renders, i.e. whenever there is anything
    # to report.
    git_status = gitCounters // {
      format = "$stashed$staged$modified$deleted$untracked$ahead_behind$conflicted[ ✗](bold red) ";
    };
    character = {
      success_symbol = ""; # λ is part of format; no extra char
      error_symbol = "[✘](bold red)";
    };
  };
in
{
  programs.starship = {
    enable = true;
    settings = if theme == "lambda" then lambda else blue;
  };
}
