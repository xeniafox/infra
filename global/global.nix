{ config, pkgs, ... }:
{
  options.allowedUnfree = pkgs.lib.mkOption {
    type = pkgs.lib.types.listOf pkgs.lib.types.str;
    default = [ ];
  };

  config.nixpkgs.config = {
    allowUnfreePredicate = pkg: pkgs.lib.elem (pkgs.lib.getName pkg) config.allowedUnfree;
  };

  config = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.networkmanager.enable = pkgs.lib.mkDefault true;
    networking.nameservers = pkgs.lib.mkDefault [ "1.1.1.1" "8.8.8.8" ];

    time.timeZone = pkgs.lib.mkDefault "America/Bahia";

    i18n.defaultLocale = pkgs.lib.mkDefault "en_US.UTF-8";
    i18n.extraLocaleSettings = pkgs.lib.mkDefault {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "unir" ''NIXPKGS_ALLOW_BROKEN=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 NIXPKGS_ALLOW_UNFREE=1 nix run nixpkgs#$1 --impure -- ''${@:2}'')
      (writeShellScriptBin "unir" ''NIXPKGS_ALLOW_UNFREE=1 nix run nixpkgs#$1 --impure -- ''${@:2}'')
      (writeShellScriptBin "nir" ''nix run nixpkgs#$1 -- ''${@:2}'')
      (writeShellScriptBin "nxs" ''nix search nixpkgs $@'')

      gnupg

      file
      busybox
      openssh
      tmux
      openssl

      vim
      neovim
    ];

    system.stateVersion = "24.05";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    systemd.tmpfiles.rules = [
      "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
    ];

    programs.nix-ld.enable = true;
  };
}
