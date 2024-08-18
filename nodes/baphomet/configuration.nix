{ config, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "baphomet";
  networking.networkmanager.enable = true;

  users.users.malwareskunk = {
    description = "MalwareSkunk";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [
      tree
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAqmDqRIyYfc7+Et/uj8BAbJuOy7B3GpV0MKNegeKCT3 malwareskunk@hologramsummeragain"
    ];
  };

  environment.systemPackages = with pkgs; [
    neovim
    k3s
    cifs-utils
    nfs-utils
    git
    kubernetes-helm
    helmfile
  ];

  services.openssh.enable = true;

  networking.firewall.enable = false;
  #networking.firewall.allowedTCPPorts = [ 22 ];
  #networking.firewall.allowedUDPPorts = [  ];

  virtualisation.docker = {
    enable = true;

    storageDriver = "btrfs";
    logDriver = "json-file";

    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString([
      "--write-kubeconfig-mode \"0644\""
      "--cluster-init"
      "--disable servicelb"
      "--disable traefik"
    ]);
    clusterInit = true;
  };
}

