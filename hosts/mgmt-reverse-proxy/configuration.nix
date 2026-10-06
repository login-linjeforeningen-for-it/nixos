{
  config,
  lib,
  ...
}: let
  domain = "login.no";

  mgmt = {
    idrac1.urls = ["https://10.10.0.17"];
    idrac2.urls = ["https://10.10.0.18"];
    idrac3.urls = ["https://10.10.0.19"];
    pelican.urls = ["http://10.20.0.20"];
    pfsense.urls = ["https://10.20.0.10:10443"];
    truenas.urls = ["https://10.10.0.30"];
    usb.urls = ["https://10.20.0.91"];

    pve = {
      urls = [
        "https://10.10.0.11:8006"
        "https://10.10.0.12:8006"
      ];
      extra = {
        healthCheck = {
          path = "/";
          interval = "10s";
          timeout = "3s";
        };
        sticky.cookie = {
          name = "pve_sticky_session";
          httpOnly = true;
        };
      };
    };
  };

  localNames = lib.attrNames mgmt ++ ["onprem"];

  sniRule = "HostSNIRegexp(`^(${
    lib.concatMapStringsSep "|" lib.escapeRegex localNames
  })\\.${lib.escapeRegex domain}$`)";
in {
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [80 443];
  };

  systemd.services.traefik.environment.OVH_ENDPOINT = "ovh-ca";

  services.traefik = {
    enable = true;
    environmentFiles = [
      "/etc/traefik/ovh.env"
    ];

    staticConfigOptions = {
      entryPoints = {
        http = {
          address = ":80";
          http.redirections.entrypoint = {
            to = "https";
            scheme = "https";
          };
        };

        https.address = ":443";

        local = {
          address = "127.0.0.1:9443";
          asDefault = true;
          http.tls.certResolver = "letsencrypt";
          transport.respondingTimeouts.idleTimeout = "10m";
          proxyProtocol.trustedIPs = ["127.0.0.1/32"];
        };
      };

      log = {
        level = "INFO";
        filePath = "${config.services.traefik.dataDir}/traefik.log";
        format = "json";
      };

      ping.manualRouting = true;

      certificatesResolvers.letsencrypt.acme = {
        email = "postmaster@login.no";
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge.provider = "ovh";
      };
    };

    dynamicConfigOptions = {
      http.serversTransports.insecureTransport.insecureSkipVerify = true;

      http.routers =
        lib.mapAttrs (name: _: {
          service = name;
          entryPoints = ["local"];
          rule = "Host(`${name}.${domain}`)";
        })
        mgmt
        // {
          onprem = {
            service = "ping@internal";
            entryPoints = ["local"];
            rule = "Host(`onprem.${domain}`)";
          };
        };

      http.services =
        lib.mapAttrs (_: c: {
          loadBalancer =
            {servers = map (url: {inherit url;}) c.urls;}
            // lib.optionalAttrs (lib.any (lib.hasPrefix "https://") c.urls) {
              serversTransport = "insecureTransport";
            }
            // (c.extra or {});
        })
        mgmt;

      tcp.routers = {
        mgmt-native = {
          rule = sniRule;
          entryPoints = ["https"];
          tls.passthrough = true;
          service = "mgmt-local";
          priority = 100;
        };
        cluster = {
          rule = "HostSNI(`*`)";
          entryPoints = ["https"];
          tls.passthrough = true;
          service = "cluster";
          priority = 1;
        };
      };

      tcp.services = {
        mgmt-local.loadBalancer = {
          servers = [{address = "127.0.0.1:9443";}];
          proxyProtocol.version = 2;
        };
        cluster.loadBalancer = {
          servers = [{address = "10.30.0.41:443";}];
          proxyProtocol.version = 2;
        };
      };
    };
  };
}
