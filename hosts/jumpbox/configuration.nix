{lib, ...}: {
  boot.initrd.availableKernelModules = ["ahci"];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  users.users.tekkom = {
    extraGroups = lib.mkForce [];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdNa+94cvRT4paS6oBC82mDr0z799BJrmc0JE9fXRqQ hermpett@nixos"
    ];
  };
}
