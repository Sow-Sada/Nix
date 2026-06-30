{
  description = "Sada's NixOS workstation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    # Do NOT add a nixpkgs.follows on the kernel input. It pins its own
    # nixpkgs so the prebuilt kernel matches the binary cache.
  };

  outputs = { self, nixpkgs, nix-cachyos-kernel, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
          # Verify the exact variant with:
          #   nix flake show github:xddxdd/nix-cachyos-kernel/release
          # and swap in the x86_64-v4 build for your Zen 5 chip if listed.
          boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v4;        })
      ];
    };
  };
}
