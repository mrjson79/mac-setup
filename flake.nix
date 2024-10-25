{
  description = "Work";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, nix-vscode-extensions }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.neovim
          pkgs.ansible
          pkgs.ansible-language-server
          pkgs.ansible-lint
          pkgs.btop
          pkgs.curl
          pkgs.fd
          pkgs.fzf
          pkgs.gawk
          pkgs.git
          pkgs.git-filter-repo
          pkgs.less
          pkgs.openssh
          pkgs.shellcheck
          pkgs.tree
          pkgs.watch
          pkgs.wget
          pkgs.mkalias
          pkgs.zsh
          pkgs.eza
          pkgs.kubecolor
          pkgs.jq
          pkgs.opentofu
          pkgs.kubectx
          pkgs.terraform-ls
          pkgs.yq
          pkgs.terraform-docs
          pkgs.pre-commit
          pkgs.tfsec
          pkgs.checkov
          pkgs.pwgen
          pkgs.talosctl
          pkgs.raycast
        ];
        # Activate Homebrew and install brew packages
        homebrew = {
          enable = true;
          brews = [
            "mas"
            "kubernetes-cli"
          ];
          casks = [
            "duckduckgo"
            "mullvad-browser"
            "slack"
            "vmware-fusion"
            "warp"
          ];
          # For Mac Appstore apps
          masApps = {};

          #onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
        };

      # Activation script for spotlight
      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
            '';

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Add fingerprint for nix-darwin
      security.pam.enableSudoTouchIdAuth = true;

      # Home-manager config misc
      users.users.andersjohansson.home = "/Users/andersjohansson";
      home-manager.backupFileExtension = "backup";
      nix.configureBuildUsers = true;
      nix.useDaemon = true;

      # Adding some Macos system defaults
      system.defaults = {
        #dock
        dock.autohide = true;
        dock.mru-spaces = false;
        dock.appswitcher-all-displays = true;
        dock.tilesize = 48;
        dock.orientation = "left";
        #finder
        finder.AppleShowAllExtensions= true;
        finder.FXDefaultSearchScope = "SCcf";
        finder.FXPreferredViewStyle = "clmv";
        finder.FXEnableExtensionChangeWarning = false;
        #finder.FXRemoveOldTrashItems = true; maybe home-manager
        #finder.NewWindowTarget = "PfHm"; maybe home-manager
        #finder.ShowRecentTags = true; maybe home-manager
        #finder.WarnOnEmptyTrash = false; maybe home-manager
        #loginwindow
        loginwindow.LoginwindowText = "Welcome To Work";
        loginwindow.GuestEnabled = false;
        #screencapture
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 20;
        #NSGlobalDomain
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.AppleKeyboardUIMode = 3;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.KeyRepeat = 2;
        NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
        NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
        NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."work" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.users.andersjohansson = import ./home.nix;

          nixpkgs.overlays = [
            inputs.nix-vscode-extensions.overlays.default
          ];
        }
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            # Apple Silicon Only
            enableRosetta = true;
            # User owning the Homebrew Prefix
            user = "andersjohansson";
            # Migrate existing Homebrew
            autoMigrate = true;
          };
        }
         ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."work".pkgs;
  };
}
