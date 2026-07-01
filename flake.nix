{
  description = "Sada's NixOS workstation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    # Do NOT add a nixpkgs.follows on the kernel input. It pins its own
    # nixpkgs so the prebuilt kernel matches the binary cache.

    nordvpn = {
      url = "github:connerohnesorge/nordvpn-flake";
      inputs.nixpkgs.follows = "nixpkgs";

      # Override the flake's dead 4.2.0 pin with the current pool release.
      # Nord's pool only keeps the newest deb, so this will need bumping
      # whenever they cut a release. Check the live version first (see below).
      inputs.nordvpn-amd64-deb = {
        url = "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/nordvpn_5.0.0_amd64.deb";
        flake = false;
      };
      inputs.nordvpn-arm64-deb = {
        url = "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/nordvpn_5.0.0_arm64.deb";
        flake = false;
      };
    };
  };

  outputs = { self, nixpkgs, nix-cachyos-kernel, nordvpn, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        nordvpn.nixosModules.default
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
          # Verify the exact variant with:
          #   nix flake show github:xddxdd/nix-cachyos-kernel/release
          # and swap in the x86_64-v4 build for your Zen 5 chip if listed.
          boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v4;
        })
      ];
    };
  };
}
