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
  site = pkgs.runCommand "tadix-site" { } ''
    mkdir -p $out/en
    cp ${./site/index.html} $out/index.html
    cp ${./site/en/index.html} $out/en/index.html
    cp ${./site/style.css} $out/style.css
  '';
  biolabSrc = pkgs.fetchFromGitea {
    domain = "git.tadix.dev";
    owner = "ltadeu6";
    repo = "BioLab";
    rev = "eed063f16c8dd9248529a864840c30171feacdc2";
    hash = "sha256-Uot/ETx+RpBtNZG/0BsZxcXinPZGEDoUJSAFLIg4j9E=";
  };
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

  nix.settings.require-sigs = false;

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
    "d /etc/nextcloud-secrets 0750 nextcloud nextcloud -"
  ];

  environment.etc."jupyter/jupyter_server_config.py".text = ''
    c.ServerApp.ip = "127.0.0.1"
    c.ServerApp.port = 8888
    c.ServerApp.open_browser = False
    c.ServerApp.allow_remote_access = True
    c.ServerApp.root_dir = "/home/${username}/notebooks"
    c.PasswordIdentityProvider.hashed_password = "argon2:$argon2id$v=19$m=10240,t=10,p=8$aEgLh24uXxt6zrk9ndQM2Q$U4bfEybs+dRNl1cBPUOInen6nXShOIjWd67LmuGar1Q"
    c.PasswordIdentityProvider.password_required = True
  '';

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "ltadeu6@gmail.com";
  };

  services.nginx = {
    enable = true;
    virtualHosts."tadix.dev" = {
      enableACME = true;
      forceSSL = true;
      root = "${site}";
    };
    virtualHosts."nextcloud.tadix.dev" = {
      enableACME = true;
      forceSSL = true;
    };
    virtualHosts."git.tadix.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
    virtualHosts."biolab.tadix.dev" = {
      enableACME = true;
      forceSSL = true;
      root = "${biolabSrc}/www";
    };
    virtualHosts."jupyter.tadix.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8888";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_read_timeout 300s;
        '';
      };
    };
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "nextcloud.tadix.dev";
    https = true;
    database.createLocally = true;
    config = {
      adminuser = "ltadeu6";
      adminpassFile = "/etc/nextcloud-secrets/admin-password";
      dbtype = "pgsql";
    };
    phpOptions."opcache.interned_strings_buffer" = "16";
    settings = {
      default_phone_region = "BR";
      maintenance_window_start = 1;
    };
  };

  systemd.services.nextcloud-minimize = {
    description = "Configure Nextcloud for minimal file-storage use";
    after = [ "nextcloud-setup.service" ];
    requires = [ "nextcloud-setup.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "nextcloud";
      Group = "nextcloud";
    };
    unitConfig.X-Restart-Triggers = [
      (builtins.toFile "nextcloud-minimize-trigger" ''
        defaultapp=files
        disabled=activity,calendar,contacts,dashboard,firstrunwizard,photos,weather_status,circles,recommendations,user_status,systemtags
        theme=dark,#7aa2f7,plain
        repair=mimetypes
      '')
    ];
    script = ''
      set -eu
      occ=/run/current-system/sw/bin/nextcloud-occ

      $occ config:system:set defaultapp --value=files

      for app in activity calendar contacts dashboard firstrunwizard photos weather_status circles recommendations user_status systemtags; do
        $occ app:disable "$app" 2>/dev/null || true
      done

      $occ config:app:set theming defaultColorScheme --value=dark
      $occ config:app:set theming color --value="#7aa2f7"
      $occ config:app:set theming background --value="plain"
      $occ config:app:set theming name --value="Files"
      $occ config:app:set theming slogan --value=""

      $occ maintenance:repair --include-expensive
    '';
  };

  services.forgejo = {
    enable = true;
    database.type = "sqlite3";
    settings = {
      server = {
        DOMAIN = "git.tadix.dev";
        ROOT_URL = "https://git.tadix.dev";
        HTTP_PORT = 3000;
        SSH_DOMAIN = "git.tadix.dev";
      };
      service.DISABLE_REGISTRATION = true;
      log.LEVEL = "Warn";
    };
  };

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
