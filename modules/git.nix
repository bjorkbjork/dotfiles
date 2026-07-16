{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Francois van Kempen";
        email = "francois@francoisvankempen.com";
      };

      alias = {
        st = "status -sb";
        co = "checkout";
        br = "branch";
        lg = "log --oneline --graph --decorate --all";
        last = "log -1 HEAD --stat";
        amend = "commit --amend --no-edit";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.conflictStyle = "zdiff3";
      rerere.enabled = true;
      diff.colorMoved = "default";
    };
  };

  # Syntax-highlighted diff pager.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
  };

  programs.lazygit.enable = true;
}
