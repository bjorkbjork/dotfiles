{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Francois van Kempen";
    userEmail = "francois@francoisvankempen.com";

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
      };
    };

    aliases = {
      st = "status -sb";
      co = "checkout";
      br = "branch";
      lg = "log --oneline --graph --decorate --all";
      last = "log -1 HEAD --stat";
      amend = "commit --amend --no-edit";
    };

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.conflictStyle = "zdiff3";
      rerere.enabled = true;
      diff.colorMoved = "default";
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
  };

  programs.lazygit.enable = true;
}
