{pkgs, ...}: {
  networking.hostName = "honeypot";
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
    "9.9.9.9"
    "149.112.112.112"
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443];
  };

  users.users.tekkom = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker"];
  };

  environment.systemPackages = with pkgs; [
    docker
    git
    age
    _1password-cli
  ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ];

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      userland-proxy = false;
      live-restore = true;
      no-new-privileges = true;
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
      dns = [
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
        "8.8.4.4"
        "9.9.9.9"
        "149.112.112.112"
      ];
    };
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 3 * * * root /usr/bin/docker image prune -a -f --filter 'until=168h' >/dev/null 2>&1"
      "10 3 * * * root /usr/bin/docker container prune -f --filter 'until=168h' >/dev/null 2>&1"
      "20 3 * * * root /usr/bin/docker builder prune -a -f --filter 'until=168h' >/dev/null 2>&1"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    bantime-increment.enable = true;
    jails.sshd.settings = {
      enabled = true;
      mode = "aggressive";
    };
  };

  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    randomizedDelaySec = "45min";
    allowReboot = false;
  };

  services.journald.extraConfig = ''
    SystemMaxUse=512M
    RuntimeMaxUse=128M
    MaxFileSec=7day
  '';
}
