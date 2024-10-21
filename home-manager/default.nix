{ pkgs, ... }: {
  imports = [
    ./zsh.nix
    ./git.nix
  ];

  home = with pkgs; [
    ansible
    ansible-language-server
    ansible-lint
    btop
    curl
    fd
    fzf
    gawk
    git
    git-filter-repo
    less
    openssh
    shellcheck
    tree
    watch
    mkalias
    eza
    kubecolor
    jq
    bat
  ]
}