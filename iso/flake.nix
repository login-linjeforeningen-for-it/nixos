{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: {
    nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          security.sudo.wheelNeedsPassword = false;
          users.users = {
            builder = {
              openssh.authorizedKeys.keys = [
                (builtins.readFile ../id_ed25519.pub)
              ];
              isNormalUser = true;
              extraGroups = ["wheel"];
            };
          };
          nix.settings.trusted-users = [
            "builder"
          ];
          services.openssh.enable = true;
          services.qemuGuest.enable = true;
          system.stateVersion = "25.11";
        }
      ];
    };
  };
}
