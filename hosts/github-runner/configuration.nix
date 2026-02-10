{pkgs, ...}:{
  fileSystems."/mnt/truenas" = {
    device = "192.168.1.107:/mnt/storage0/iso";
    fsType = "nfs";
  };
  systemd.tmpfiles.settings = {
    mnt = {
      "/mnt/truenas" = {
        d = {
          group = "root";
          mode = "0755";
          user = "root";
        };
      };
    };
  };
  virtualisation.diskSize = 32 * 1024; # 32 GB
  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = [ "nfs" ];
  services.github-runners = {
    proxmox1 = {
      url = "https://github.com/Login-Linjeforening-for-IT";
      name = "Proxmox 1";
      enable = true;
      extraLabels = [ "nixos" ];
      tokenFile = "/var/lib/github-runner/token";
      extraPackages = with pkgs; [
        nixos-rebuild
      ];
    };
  };
}