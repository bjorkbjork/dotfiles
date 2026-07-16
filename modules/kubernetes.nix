{ pkgs, ... }:

{
  # Global on purpose: used to poke at client clusters from anywhere,
  # not just inside the monorepo devenv.
  home.packages = with pkgs; [
    k9s
    kubectl
    kubernetes-helm
  ];

  xdg.configFile."k9s/aliases.yaml".source = ../files/k9s/aliases.yaml;
}
