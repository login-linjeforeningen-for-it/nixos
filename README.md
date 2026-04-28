# Nixos machines
This is a repo for Login's Nixos machines.
## Adding a new configuration
1. Add a new folder in hosts. The name of the folder will be the hostname of the machine.
2. In the folder create a file called `configuration.nix`
3. Add the configuration in the new file
4. Push the code to main
## Deploying a new configuration
1. Create a vm with the nixos-26.05 iso. Remember to enable quemu guest agent.
2. Run the install pipeline with the ip of the new vm with the name of the configuration you want to install.
## Updating a machine
1. Push the code to main.
2. Run the update pipeline with the target machine and the name of the configuration you want to apply.
## Updating the base ISO
1. Run `nixos-rebuild build-image --image-variant iso --flake iso/#iso`