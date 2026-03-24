{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    disko,
    ...
  }: {
    nixosConfigurations = let
      # Fetch all of the directories in the hosts folder
      hosts = builtins.attrNames (nixpkgs.lib.filterAttrs (n: t: t == "directory") (builtins.readDir ./hosts));
    in
      # Map the hosts to nixosConfigurations
      builtins.listToAttrs
      (map
        (host: {
          name = host;
          value = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit host;
            };
            modules = [
              disko.nixosModules.disko
              ./common.nix
              (./hosts + "/${host}/configuration.nix")
            ];
          };
        })
        hosts);
  };
}
