{...}:
{
  services.openssh.enable = true;
  services.qemuGuest.enable = true;
  security.sudo.wheelNeedsPassword = false;
  users.users.nixos = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwq+TcTSfAMKHyYKB9O3F9iGbhZvXzXAIwmSDTf6nYY"
    ];
    extraGroups = ["wheel"];
  };
  system.stateVersion = "25.11";
}
