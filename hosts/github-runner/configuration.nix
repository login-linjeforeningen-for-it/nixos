{...}:{
  # GitHub runner configuration for this host
  services.github-runners = {
    proxmox1 = {
      url = "https://github.com/login-linjeforeningen-for-it";
      name = "Proxmox 1";
      enable = true;
      extraLabels = [ "nixos" ];
      tokenFile = "/var/lib/github-runner/token";
    };
  };
}