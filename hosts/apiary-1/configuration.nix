{pkgs, ...}: {
  # Single-node k3s cluster.

  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs.k3s_1_35;

    clusterInit = true;

    disable = [
      "traefik"
      "servicelb"
    ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      6443 # Kubernetes API
    ];
  };

  environment.etc."rancher/k3s/config.yaml".text = ''
    etcd-s3: true
    etcd-s3-config-secret: k3s-etcd-s3
    etcd-snapshot-schedule-cron: "0 */6 * * *"
    etcd-snapshot-retention: 20
    etcd-snapshot-compress: true

    tls-san:
      - apiary.login.no
      - 10.30.0.30
      - 10.30.0.188
  '';
}
