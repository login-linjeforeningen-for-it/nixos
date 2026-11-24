{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    wazuh.url = "github:nealfennimore/wazuh-nixos/45e5adfe76d70e879a408c611c310b704fa1fa06";
  };

  outputs = {
    nixpkgs,
    disko,
    wazuh,
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
              wazuh.nixosModules.wazuh-agent
              {services.wazuh-agent.package = wazuh.packages.x86_64-linux.wazuh-agent;}
              ./common.nix
              (./hosts + "/${host}/configuration.nix")
            ];
          };
        })
        hosts);
  };
}
