{ pkgs, ... }:
let
  username = "ltadeu6";
  sshAuthorizedKeys = [
    ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtg8wYZkp59veN/+wiF/nD6cQimOctVL0TpIIPYNCibFsXvh3c20p0lGpHUxp+yZZxqToQxIKeQzgx2nwdlVqN7zxco9T9N4Kg3QlbFuUWZ0k1jovxcORkBEYSuJ0FM/KLN8zJIRgArm3diMqj9t0fYzCZCPJg2TPi7eziBnkCT3FiuZKI6C23oFPoDqt4z1Hl83VHJipn98vPJCJ43uyb5yNZoEnD2hPErdvwOiYB6FE8pSgqWPuHxgScgG5aM0RxnoyzVyEAk5mQ1aeEr2F2gp/R4ApvYu5bF3iCEgg/17DvkyRpDz5WkOXr/r7c4Lbt3NwM5moAnomAVYySwITmmezBIovJC96LR3zMF90Bwt3rcCIhm1ahmFKSaf3HasERVz9zJAnP+WncEeJWvrO91qCQxqq1pw4CR1Shk+PvjXJUEfTmWGoXnNPlO6y2NevXKwWzX6HDumqVLM486+eQUsQZ9L9dhVNI2B5FxPKL2OvR0WWjoPO9yiPouHO7bb0= u0_a254@localhost
    ''
    ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBitXAExTzEy48juhqlKANx/oYqnxpR7J6BCKsBXt8iH ltadeu6@nixos
    ''
  ];
  jupyterEnv = pkgs.python3.withPackages (ps:
    with ps; [
      ipykernel
      ipython
      jupyterlab
      matplotlib
      numpy
      pandas
    ]);
in {
  imports = [
    ./hardware-configuration.nix
  ];

  environment.systemPackages = with pkgs; [
    curl
    fd
    git
    htop
    jupyterEnv
    neovim
    ripgrep
    starship
    tmux
    wget
  ];

  services.logrotate.checkConfig = false;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking.hostName = "NixOracle";
  networking.domain = "";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  systemd.tmpfiles.rules = [
    "d /home/${username}/notebooks 0750 ${username} users -"
  ];

  environment.etc."jupyter/jupyter_server_config.py".text = ''
    c.ServerApp.ip = "127.0.0.1"
    c.ServerApp.port = 8888
    c.ServerApp.open_browser = False
    c.ServerApp.allow_remote_access = False
    c.ServerApp.token = ""
    c.ServerApp.password = ""
    c.ServerApp.root_dir = "/home/${username}/notebooks"
  '';

  systemd.services.jupyter-lab = {
    description = "Single-user JupyterLab";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = username;
      Group = "users";
      WorkingDirectory = "/home/${username}/notebooks";
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart =
        "${jupyterEnv}/bin/jupyter-lab --config=/etc/jupyter/jupyter_server_config.py";
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };
  programs.git.enable = true;
  programs.htop.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.starship.enable = true;

  users.defaultUserShell = pkgs.fish;
  users.users.root.openssh.authorizedKeys.keys = sshAuthorizedKeys;
  users.users.${username} = {
    isNormalUser = true;
    description = "Lucas Tadeu";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = sshAuthorizedKeys;
  };

  system.stateVersion = "23.11";
}
