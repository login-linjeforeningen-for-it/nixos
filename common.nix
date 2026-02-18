{host, lib, ...}:
{
  networking.hostName = host;
  services.openssh.enable = true;
  services.qemuGuest.enable = true;
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
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = [
        "tekkom"
      ];
    };
  };
  security.sudo.wheelNeedsPassword = false;
  users.users.tekkom = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      (lib.strings.removeSuffix "\n" (builtins.readFile ./id_ed25519.pub))
    ];
  };
  system.stateVersion = "25.11";
}
