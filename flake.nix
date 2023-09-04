{
  description = "tcarrio's NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    # You can access packages and modules from different nixpkgs revs at the
    # same time. See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    vscode-server.url = "github:msteen/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { self
    , nix-formatter-pack
    , nixpkgs
    , vscode-server
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "23.05";
      libx = import ./lib { inherit inputs outputs stateVersion; };
    in
    {
      # home-manager switch -b backup --flake $HOME/Zero/nix-config
      # nix build .#homeConfigurations."tcarrio@ripper".activationPackage
      homeConfigurations = {
        # .iso images
        "nuc@iso-nuc" = libx.mkHome { hostname = "iso-nuc"; username = "nixos"; };
        "tk1@iso-tk1" = libx.mkHome { hostname = "iso-tk1"; username = "nixos"; };

        # Workstations
        "tcarrio@designare" = libx.mkHome { hostname = "designare"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@glass" = libx.mkHome { hostname = "glass"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@micropc" = libx.mkHome { hostname = "micropc"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@p1" = libx.mkHome { hostname = "p1"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@p2-max" = libx.mkHome { hostname = "p2-max"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@ripper" = libx.mkHome { hostname = "ripper"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@t510" = libx.mkHome { hostname = "t510"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@trooper" = libx.mkHome { hostname = "trooper"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@vm" = libx.mkHome { hostname = "vm"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@win2" = libx.mkHome { hostname = "win2"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@win-max" = libx.mkHome { hostname = "win-max"; username = "tcarrio"; desktop = "pantheon"; };
        "tcarrio@zed" = libx.mkHome { hostname = "zed"; username = "tcarrio"; desktop = "pantheon"; };

        # Servers
        "tcarrio@brix" = libx.mkHome { hostname = "brix"; username = "tcarrio"; };
        "tcarrio@skull" = libx.mkHome { hostname = "skull"; username = "tcarrio"; };
        "tcarrio@vm-mini" = libx.mkHome { hostname = "vm-mini"; username = "tcarrio"; };
      };

      nixosConfigurations = {
        # .iso images
        #  - nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        iso-nuc = libx.mkHost { systemType = "iso"; hostname = "iso-nuc"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; };
        iso-tk1 = libx.mkHost { systemType = "iso"; hostname = "iso-tk1"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; };
        iso-console = libx.mkHost { systemType = "iso"; hostname = "iso-console"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; };
        iso-desktop = libx.mkHost { systemType = "iso"; hostname = "iso-desktop"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; };
        
        # Workstations
        #  - sudo nixos-rebuild switch --flake $HOME/Zero/nix-config
        #  - nix build .#nixosConfigurations.ripper.config.system.build.toplevel
        glass = libx.mkHost { systemType = "workstation"; hostname = "glass"; username = "tcarrio"; desktop = "pantheon"; };
        t510 = libx.mkHost { systemType = "workstation"; hostname = "t510"; username = "tcarrio"; desktop = "pantheon"; };
        vm = libx.mkHost { systemType = "workstation"; hostname = "vm"; username = "tcarrio"; desktop = "pantheon"; };

        # Servers
        # Can be executed locally:
        #  - sudo nixos-rebuild switch --flake $HOME/Zero/nix-config
        #
        # Or remotely:
        #  - nixos-rebuild switch --fast --flake .#${HOST} \
        #      --target-host ${USERNAME}@${HOST}.${TAILNET} \
        #      --build-host ${USERNAME}@${HOST}.${TAILNET}
        brix = libx.mkHost { systemType = "server"; hostname = "brix"; username = "tcarrio"; };
        skull = libx.mkHost { systemType = "server"; hostname = "skull"; username = "tcarrio"; };
        vm-mini = libx.mkHost { systemType = "server"; hostname = "vm-mini"; username = "tcarrio"; };
      };

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      devShells = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; }
      );

      # nix fmt
      formatter = libx.forAllSystems (system:
        nix-formatter-pack.lib.mkFormatter {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            alejandra.enable = false;
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        }
      );

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );
    };
}
