# 
 {config, pkgs, ... }:

{
  # TODO please change the username & home directory to your own
  home.username = "andersjohansson";
  home.homeDirectory = "/Users/andersjohansson";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

    # neofetch
  ];
  home.sessionVariables = {
    EDITOR = "vim";
  };
  home.file = {
    ".vimrc".source = ./dotfiles/vim_configuration;
    ".zshrc".source = ./dotfiles/zsh_configuration;
    "./dotfiles/.aliases".source = ./dotfiles/aliases;
    "./dotfiles/.kubectl_aliases".source = ./dotfiles/kubectl_aliases;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    mutableExtensionsDir = false;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;

    extensions = with pkgs.open-vsx; [
      # https://raw.githubusercontent.com/nix-community/nix-vscode-extensions/master/data/cache/open-vsx-latest.json
      leodevbro.blockman
      bbenoist.nix
      pinage404.nix-extension-pack
      jnoortheen.nix-ide
      oderwat.indent-rainbow
      hashicorp.hcl
    ];
  };
  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}