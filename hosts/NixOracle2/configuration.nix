{ pkgs, ... }:
let
  sshAuthorizedKeys = [
    ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtg8wYZkp59veN/+wiF/nD6cQimOctVL0TpIIPYNCibFsXvh3c20p0lGpHUxp+yZZxqToQxIKeQzgx2nwdlVqN7zxco9T9N4Kg3QlbFuUWZ0k1jovxcORkBEYSuJ0FM/KLN8zJIRgArm3diMqj9t0fYzCZCPJg2TPi7eziBnkCT3FiuZKI6C23oFPoDqt4z1Hl83VHJipn98vPJCJ43uyb5yNZoEnD2hPErdvwOiYB6FE8pSgqWPuHxgScgG5aM0RxnoyzVyEAk5mQ1aeEr2F2gp/R4ApvYu5bF3iCEgg/17DvkyRpDz5WkOXr/r7c4Lbt3NwM5moAnomAVYySwITmmezBIovJC96LR3zMF90Bwt3rcCIhm1ahmFKSaf3HasERVz9zJAnP+WncEeJWvrO91qCQxqq1pw4CR1Shk+PvjXJUEfTmWGoXnNPlO6y2NevXKwWzX6HDumqVLM486+eQUsQZ9L9dhVNI2B5FxPKL2OvR0WWjoPO9yiPouHO7bb0= u0_a254@localhost
    ''
    ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBitXAExTzEy48juhqlKANx/oYqnxpR7J6BCKsBXt8iH ltadeu6@nixos
    ''
    # Chave usada pelo bootstrap deste host (mesma do par de API da OCI).
    # TODO: rotacionar para uma chave SSH dedicada e remover esta entrada.
    ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCSVWCYyh32wJdjk6YfwSgAQcvzunta1C2RTrLWfyzief7D1D86Kc+jpvaULllrP8+ZfTiEOecUfj37HJAxtO6ZIje/ZdZVGObgDH8m7eaNSTR14VKNnlgz+gwx9plskUj4hwwncgssKWjQfObNKlwo2oePKI9Y9Q78ag5n2mm7HKT7PbdbBEzeN88oe9mMw92tLSmPI8wSi0FHxQOptHscvyyWV4wgIFpW8Xnc+Lk2vbR9s9vA5LAtH754aDBw4WqW/3neT4cS5sd9+8f/FxdG41NJAzJUkg/XZevGABH6GojMKfdycveH/9NueNggwFY9b1MDke8+Pm2FhXIkDFtt
    ''
  ];
in {
  imports = [
    ./hardware-configuration.nix
  ];

  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    neovim
    ripgrep
    tmux
    wget
  ];

  services.logrotate.checkConfig = false;

  boot.tmp.cleanOnBoot = true;

  networking = {
    hostName = "NixOracle2";
    domain = "";
    useDHCP = true;
    firewall.allowedTCPPorts = [ 22 ];
  };

  time.timeZone = "America/Sao_Paulo";

  # 1 GB de RAM nesta shape; zram basta enquanto os rebuilds forem feitos
  # remotamente. O /swapfile de 2 GB do bootstrap foi para /old-root pelo
  # lustrate; nao referencie ele em swapDevices.
  zramSwap.enable = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };

  users.users.root.openssh.authorizedKeys.keys = sshAuthorizedKeys;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # O infect subiu esta maquina no canal 25.11 (unico canal comprovadamente
  # funcional nesta shape - ver AGENTS.md). system.stateVersion segue esse
  # canal ate um upgrade explicito.
  system.stateVersion = "25.11";
}
