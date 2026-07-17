{
  description = "Francois' portable development environment — clone, switch, done.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim environment: editor, LSPs, formatters. The Lua config itself is
    # cloned to ~/.config/nvim as a live checkout (see modules/nvim.nix).
    nvim-config = {
      url = "github:bjorkbjork/nvim-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    albafetch = {
      url = "github:alba4k/albafetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      homeConfigurations."francois" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
    };
}
