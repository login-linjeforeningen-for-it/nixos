{host, ...}: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.extra-substituters = ["https://wazuh.cachix.org"];
  nix.settings.extra-trusted-public-keys = ["wazuh.cachix.org-1:NflEnqc62gXNPSzRtdOmuzDyfGK7yrTc6C2znraX3B8="];
  networking.hostName = host;
  services.openssh.enable = true;
  services.qemuGuest.enable = true;
  services.wazuh-agent = {
    enable = true;
    manager.host = "54.37.233.253"; # secbee
  };
  services.opkssh = rec {
    enable = true;
    providers = {
      authentik = {
        issuer = "https://authentik.login.no/application/o/jumpbox/";
        clientId = "uV8fAROsKRWXEn09ovLRDA5Xa5GPZ7AX92isC3jl";
      };
    };
    authorizations = [
      {
        user = "tekkom";
        principal = "oidc:groups:TekKom";
        inherit (providers.authentik) issuer;
      }
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  users.users = {
    tekkom = {
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
    builder = {
      openssh.authorizedKeys.keys = [
        (builtins.readFile
        ./id_ed25519.pub)
      ];
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };
  nix.settings.trusted-users = [
    "builder"
  ];
  system.stateVersion = "25.11";
}
