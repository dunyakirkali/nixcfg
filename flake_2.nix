{
  description = "D's Machine";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    unstable.url = "nixpkgs/nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv/latest";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, unstable, home-manager, devenv }: {
    darwinConfigurations.dMini = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
      };
      modules = [
        ({ pkgs, ... }: {
          programs.zsh.enable = true;
          environment.shells = [pkgs.bash pkgs.zsh];
          environment.loginShell = pkgs.zsh;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';
          systemPackages = [];
          # fonts.fontDir.enable = true;
          fonts.fonts = [ (pkgs.nerdfonts.override {
            fonts = ["SourceCodePro"];
          })];
          services.nix-deamon.enable = true;
          system.defaults.finder.AppleShowAllExtensions = true;
          system.defaults.dock.auohide = true;
          system.defaults.NSGlobalDomain.InitialKeyRepeat = 14;
          system.defaults.NSGlobalDomain.KeyRepeat = 1;
          system.stateVersion = "22.11";
        })
        (inputs.home-manager.darwinModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPkgs = true;
            user.dunyakirkali.imports = [
              ({pkgs, ...}: {
                home.stateVersion = "22.11";
                home.packages = [ pkgs.ripgrep pkgs.fd];
                home.sessionVariables = {
                  PAGER = "less";
                  CLICOLOR = 1;
                  EDITOR = "nvim";
                };
                programs.bat.enable = true;
                programs.fzf.enable = true;
                programs.fzf.enableZshIntegration = true;
                programs.exa.enable = true;
                programs.git.enable = true;
                programs.zsh.enable = true;
                programs.zsh.enableCompletion = true;
                programs.zsh.enableAutosuggestions = true;
                programs.zsh.enableSyntaxHighlighting = true;
                programs.zsh.shellAliases = {
                  ls = "ls --color=uto -F";
                };
                programs.starship.enable = true;
                programs.starship.enableZshIntegration = true;
              })
            ];
          };
        })
      ];
    };
  };
}