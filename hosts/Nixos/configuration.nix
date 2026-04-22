# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, agenix, ... }: {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  age = {
    identityPaths = [ "/home/ltadeu6/.ssh/id_ed25519" ];
    secrets = { } // lib.optionalAttrs
      (builtins.pathExists ../../secrets/openai_api_key.age) {
        openai_api_key = {
          file = ../../secrets/openai_api_key.age;
          owner = "ltadeu6";
          group = "users";
          mode = "0400";
        };
      } // lib.optionalAttrs
      (builtins.pathExists ../../secrets/openclaw_gateway_token.age) {
        openclaw_gateway_token = {
          file = ../../secrets/openclaw_gateway_token.age;
          owner = "ltadeu6";
          group = "users";
          mode = "0400";
        };
      } // lib.optionalAttrs
      (builtins.pathExists ../../secrets/minecraft_rcon_password.age) {
        minecraft_rcon_password.file =
          ../../secrets/minecraft_rcon_password.age;
      } // lib.optionalAttrs
      (builtins.pathExists ../../secrets/syncthing_pixel_id.age) {
        syncthing_pixel_id.file = ../../secrets/syncthing_pixel_id.age;
      } // lib.optionalAttrs
      (builtins.pathExists ../../secrets/syncthing_tv_id.age) {
        syncthing_tv_id.file = ../../secrets/syncthing_tv_id.age;
      } // lib.optionalAttrs
      (builtins.pathExists ../../secrets/wireguard_private_key.age) {
        wireguard_private_key.file = ../../secrets/wireguard_private_key.age;
      };
  };

  nix.settings = {
    # CUDA builds are heavy; use a binary cache to avoid local compilation.
    substituters = lib.mkAfter [ "https://cache.nixos-cuda.org" ];
    trusted-public-keys = lib.mkAfter [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  powerManagement.cpuFreqGovernor = "performance";
  # Bootloader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 0;
    # plymouth.themePackages = [
    #   (pkgs.adi1090x-plymouth-themes.override {
    #     selected_themes = [ "colorful_loop" ];
    #   })
    # ];
    plymouth.enable = true;
    # plymouth.theme = "colorful_loop";
    consoleLogLevel = 0;
    kernelModules = [ "vhba" ];
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "boot.shell_on_fail"
    ];
  };

  networking = {
    hostName = "Nixos"; # Define your hostname.
    networkmanager.enable = true;
    firewall.enable = false;
    interfaces = {
      enp4s0.ipv4.addresses = [{
        address = "192.168.1.150";
        prefixLength = 16;
      }];
    };
    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    extraHosts = ''
      191.252.194.81 vps
    '';
    # Enable WireGuard
    # wireguard.interfaces = {
    #   wg0 = {
    #     ips = [ "10.0.0.2/24" ];
    #     listenPort = 51820;
    #     privateKey = builtins.readFile config.age.secrets.wireguard_private_key.path;
    #     peers = [{
    #       publicKey = (import ../../secrets/secrets.nix).wireguard.peerPublicKey;
    #       allowedIPs = [ "10.0.0.1" ];
    #       endpoint = (import ../../secrets/secrets.nix).wireguard.endpoint;
    #       persistentKeepalive = 25;
    #     }];
    #   };
    # };
  };

  time.timeZone = "America/Sao_Paulo";

  i18n = {
    defaultLocale = "pt_BR.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };

  programs = {
    cdemu.enable = true;

    gamescope = {
      enable = true;
      capSysNice = true;
    };

    virt-manager.enable = true;

    gnupg.agent.enable = true;
    nautilus-open-any-terminal = {
      enable = true;
      terminal = "kitty";
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';
      shellInit = ''
        if test -r /run/agenix/openai_api_key
          set -gx OPENAI_API_KEY (cat /run/agenix/openai_api_key)
        end
        if test -r /run/agenix/openclaw_gateway_token
          set -gx OPENCLAW_GATEWAY_TOKEN (cat /run/agenix/openclaw_gateway_token)
        end
      '';
      shellAliases = {
        la = "exa --icons --git";
        ls = "exa --icons --git";
        tree = "exa --tree";
        rm = "trash";
      };
    };
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [ bash ];
    };
    dconf.enable = true;
    kdeconnect.enable = true;
    nano.enable = false;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    starship.enable = true;
    java.enable = true;
    htop.enable = true;
    git.enable = true;
    gamemode.enable = true;
    firefox.enable = true;
    adb.enable = true;
  };

  security.polkit.enable = true;
  services = {
    fstrim.enable = true;
    home-assistant = {
      enable = true;
      openFirewall = true;
      extraComponents = [ "lg_thinq" ];
      config = {
        homeassistant = {
          name = "Casa";
          unit_system = "metric";
          time_zone = "America/Sao_Paulo";
        };

        default_config = { };
      };
    };
    dbus.enable = true;
    displayManager.gdm.enable = true;
    # Optional but recommended if using Nautilus or Thunar
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    udisks2.enable = true;

    mysql = {
      enable = false;
      package = pkgs.mariadb;
    };
    # getty.autologinUser = "ltadeu6";
    flatpak.enable = true;
    terraria = {
      enable = false;
      openFirewall = true;
      worldPath =
        "/var/lib/terraria/.local/share/Terraria/Worlds/Vision_of_the_Stooge.wld";

    };
    minecraft-server = {
      enable = false;
      eula = true; # Accept Minecraft EULA
      package = pkgs.minecraft-server; # Use papermc for modded servers
      openFirewall = true; # Open port 25565

      declarative = true;
      serverProperties = {
        motd = "Welcome to my NixOS Minecraft Server!";
        enable-command-block = true;
        gamemode = "survival";
        difficulty = "normal";
        max-players = 20;
        white-list = false;
        enable-rcon = true;
        online-mode = false;
      } // lib.optionalAttrs (config.services.minecraft-server.enable
        && config.age.secrets ? minecraft_rcon_password) {
          "rcon.password" =
            builtins.readFile config.age.secrets.minecraft_rcon_password.path;
        };
    };

    xserver = {
      enable = true;
      # desktopManager.gnome.enable = true;
      # evaluation warning: The option `services.xserver.displayManager.gdm.enable'
      # defined in `/etc/nixos/configuration.nix' has been renamed to `services.displayManager.gdm.enable'.
    };
    ollama = {
      enable = true;
      # Nixpkgs' plain `ollama` is typically CPU-only; use the CUDA variant on NVIDIA.
      package = pkgs.unstable.ollama-cuda;
      acceleration = "cuda";
      host = "[::]";
      environmentVariables = {
        # Lower default context to keep KV cache smaller (faster + more likely to stay on GPU).
        OLLAMA_CONTEXT_LENGTH = "8192";
      };
      loadModels = [
        "gemma4:e4b"
      ];
      syncModels = true;
      # listenAddress = "10.0.0.2:11434";
    };
    open-webui = {
      enable = true;
      host = "0.0.0.0";
    };
    transmission = {
      enable = false;
      user = "ltadeu6";
      home = "/home/ltadeu6/Extra/Transmission/";
      package = pkgs.transmission_4;
      settings = {
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist = "*.*.*.*";
      };
    };
    jupyterhub = {
      enable = false;
      port = 8000;
      host = "0.0.0.0";
      kernels = {
        python3 = let
          pyEnv = pkgs.python3.withPackages (ps:
            with ps; [
              ipykernel
              ipython
              ipython-sql
              sqlalchemy
              mysqlclient
              pandas # Optional — great for working with SQL results
              prettytable
              jinja2
            ]);
        in {
          displayName = "Python 3 (SQL enabled)";
          argv = [
            "${pyEnv.interpreter}"
            "-m"
            "ipykernel_launcher"
            "-f"
            "{connection_file}"
          ];
          language = "python";
          logo32 =
            "${pyEnv}/${pyEnv.sitePackages}/ipykernel/resources/logo-32x32.png";
          logo64 =
            "${pyEnv}/${pyEnv.sitePackages}/ipykernel/resources/logo-64x64.png";
        };

        R = let
          rEnv = pkgs.rWrapper.override {
            packages = with pkgs.rPackages; [
              IRkernel # kernel do Jupyter
              ggplot2 # opcional, muito útil
              dplyr # idem
              tidyr
              readr
            ];
          };
        in {
          displayName = "R";
          language = "R";
          argv = [
            "${rEnv}/bin/R"
            "--slave"
            "-e"
            "IRkernel::main()"
            "--args"
            "{connection_file}"
          ];

          # O IRkernel não inclui logos — pode deixar vazio ou remover
        };
        python3-sci = let
          sciEnv = pkgs.python3.withPackages (ps:
            with ps; [
              ipykernel
              numpy
              scipy
              ipython
              jinja2
              matplotlib
              pandas # opcional, bom para tabelas
              pillow # recomendado p/ alguns backends do matplotlib
            ]);
        in {
          displayName = "Python 3 (SciPy + Matplotlib)";
          argv = [
            "${sciEnv.interpreter}"
            "-m"
            "ipykernel_launcher"
            "-f"
            "{connection_file}"
          ];
          language = "python";
          logo32 =
            "${sciEnv}/${sciEnv.sitePackages}/ipykernel/resources/logo-32x32.png";
          logo64 =
            "${sciEnv}/${sciEnv.sitePackages}/ipykernel/resources/logo-64x64.png";
        };
      };
      extraConfig = ''
        c.Authenticator.allowed_users = {"ltadeu6"};
        c.JupyterHub.admin_users = {"ltadeu6"};
      '';
    };
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "ltadeu6";

    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    emacs = { enable = true; };
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
    syncthing = {
      enable = false;
      user = "ltadeu6";
      dataDir = "/home/ltadeu6"; # Default folder for new synced folders
      configDir = "/home/ltadeu6/.config/syncthing";
      settings = {
        devices = { } // lib.optionalAttrs (config.services.syncthing.enable
          && config.age.secrets ? syncthing_pixel_id) {
            "Pixel" = {
              id = builtins.readFile config.age.secrets.syncthing_pixel_id.path;
            };
          } // lib.optionalAttrs (config.services.syncthing.enable
            && config.age.secrets ? syncthing_tv_id) {
              "TV" = {
                id = builtins.readFile config.age.secrets.syncthing_tv_id.path;
              };
            };
        folders = {
          "RetroArch" = { # Name of folder in Syncthing, also the folder ID
            path =
              "/home/ltadeu6/.config/retroarch"; # Which folder to add to Syncthing
            devices = [ "Pixel" "TV" ]; # Which devices to share the folder with
            versioning = {
              type = "simple";
              params = {
                keep = "5";
                cleanoutDays = "15";
              };
            };
          };
        };
      };
    };
  };

  console.keyMap = "br-abnt2";

  # Enable sound with pipewire.
  # sound.enable = true;
  services.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
  hardware.uinput.enable = true;
  security.rtkit.enable = true;

  environment.etc."antimicrox/controller-mouse.amgp".text = ''
<?xml version="1.0" encoding="UTF-8"?>
    <gamecontroller configversion="19" appversion="3.5.1">
      <sdlname>Controller Mouse</sdlname>
      <uniqueID>controller-mouse-default</uniqueID>
      <profilename>Desktop Mouse</profilename>
      <stickAxisAssociation index="1" xAxis="1" yAxis="2"/>
      <stickAxisAssociation index="2" xAxis="3" yAxis="4"/>
      <sets>
        <set index="1">
          <name>Desktop Mouse</name>
          <stick index="1">
            <deadZone>8000</deadZone>
            <stickbutton index="1">
              <mousespeedx>0</mousespeedx>
              <mousespeedy>-24</mousespeedy>
              <mousemode>cursor</mousemode>
              <mouseacceleration>precision</mouseacceleration>
              <slots>
                <slot>
                  <code>1</code>
                  <mode>mousemovement</mode>
                </slot>
              </slots>
            </stickbutton>
            <stickbutton index="3">
              <mousespeedx>24</mousespeedx>
              <mousespeedy>0</mousespeedy>
              <mousemode>cursor</mousemode>
              <mouseacceleration>precision</mouseacceleration>
              <slots>
                <slot>
                  <code>4</code>
                  <mode>mousemovement</mode>
                </slot>
              </slots>
            </stickbutton>
            <stickbutton index="5">
              <mousespeedx>0</mousespeedx>
              <mousespeedy>24</mousespeedy>
              <mousemode>cursor</mousemode>
              <mouseacceleration>precision</mouseacceleration>
              <slots>
                <slot>
                  <code>2</code>
                  <mode>mousemovement</mode>
                </slot>
              </slots>
            </stickbutton>
            <stickbutton index="7">
              <mousespeedx>-24</mousespeedx>
              <mousespeedy>0</mousespeedy>
              <mousemode>cursor</mousemode>
              <mouseacceleration>precision</mouseacceleration>
              <slots>
                <slot>
                  <code>3</code>
                  <mode>mousemovement</mode>
                </slot>
              </slots>
            </stickbutton>
          </stick>
          <stick index="2">
            <deadZone>9000</deadZone>
            <stickbutton index="1">
              <wheelspeedy>18</wheelspeedy>
              <slots>
                <slot>
                  <code>4</code>
                  <mode>mousebutton</mode>
                </slot>
              </slots>
            </stickbutton>
            <stickbutton index="3">
              <wheelspeedx>12</wheelspeedx>
              <slots>
                <slot>
                  <code>7</code>
                  <mode>mousebutton</mode>
                </slot>
              </slots>
            </stickbutton>
            <stickbutton index="5">
              <wheelspeedy>18</wheelspeedy>
              <slots>
                <slot>
                  <code>5</code>
                  <mode>mousebutton</mode>
                </slot>
              </slots>
            </stickbutton>
            <stickbutton index="7">
              <wheelspeedx>12</wheelspeedx>
              <slots>
                <slot>
                  <code>6</code>
                  <mode>mousebutton</mode>
                </slot>
              </slots>
            </stickbutton>
          </stick>
          <button index="1">
            <slots>
              <slot>
                <code>1</code>
                <mode>mousebutton</mode>
              </slot>
            </slots>
          </button>
          <button index="2">
            <slots>
              <slot>
                <code>3</code>
                <mode>mousebutton</mode>
              </slot>
            </slots>
          </button>
          <button index="3">
            <slots>
              <slot>
                <code>2</code>
                <mode>mousebutton</mode>
              </slot>
            </slots>
          </button>
          <button index="4">
            <slots>
              <slot>
                <code>0x46</code>
                <mode>keyboard</mode>
              </slot>
            </slots>
          </button>
          <button index="5">
            <slots>
              <slot>
                <path>/run/current-system/sw/bin/hyprctl</path>
                <arguments>dispatch workspace previous</arguments>
                <mode>execute</mode>
              </slot>
            </slots>
          </button>
          <button index="6">
            <slots>
              <slot>
                <code>0x49</code>
                <mode>keyboard</mode>
              </slot>
            </slots>
          </button>
          <button index="10">
            <slots>
              <slot>
                <path>/run/current-system/sw/bin/hyprctl</path>
                <arguments>dispatch workspace -1</arguments>
                <mode>execute</mode>
              </slot>
            </slots>
          </button>
          <button index="11">
            <slots>
              <slot>
                <path>/run/current-system/sw/bin/hyprctl</path>
                <arguments>dispatch workspace +1</arguments>
                <mode>execute</mode>
              </slot>
            </slots>
          </button>
      <button index="7">
        <slots>
          <slot>
            <path>/etc/antimicrox/player-toggle.sh</path>
            <mode>execute</mode>
          </slot>
        </slots>
      </button>
      <button index="8">
        <slots>
          <slot>
            <path>/etc/antimicrox/disable-controller.sh</path>
            <mode>execute</mode>
          </slot>
        </slots>
      </button>
      <button index="9">
        <slots>
          <slot>
            <path>/run/current-system/sw/bin/hyprctl</path>
            <arguments>dispatch killactive</arguments>
            <mode>execute</mode>
          </slot>
        </slots>
      </button>
  <dpad index="1">
    <mode>four-way</mode>
        <dpadbutton index="1">
          <slots>
            <slot>
              <code>0x01000013</code>
              <mode>keyboard</mode>
            </slot>
          </slots>
        </dpadbutton>
        <dpadbutton index="2">
          <slots>
            <slot>
              <code>0x01000014</code>
              <mode>keyboard</mode>
            </slot>
          </slots>
        </dpadbutton>
        <dpadbutton index="4">
          <slots>
            <slot>
              <code>0x01000015</code>
              <mode>keyboard</mode>
            </slot>
          </slots>
        </dpadbutton>
        <dpadbutton index="8">
          <slots>
            <slot>
              <code>0x01000012</code>
              <mode>keyboard</mode>
            </slot>
          </slots>
        </dpadbutton>
      </dpad>
          <trigger index="5">
            <triggerbutton index="2">
              <slots>
                <slot>
                  <path>/run/current-system/sw/bin/hyprctl</path>
                  <arguments>dispatch focusmonitor -1</arguments>
                  <mode>execute</mode>
                </slot>
              </slots>
            </triggerbutton>
          </trigger>
          <trigger index="6">
            <triggerbutton index="2">
              <slots>
                <slot>
                  <path>/run/current-system/sw/bin/hyprctl</path>
                  <arguments>dispatch focusmonitor +1</arguments>
                  <mode>execute</mode>
                </slot>
              </slots>
            </triggerbutton>
          </trigger>
        </set>
      </sets>
    </gamecontroller>
  '';
  environment.etc."antimicrox/player-toggle.sh" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      exec ${pkgs.playerctl}/bin/playerctl play-pause
    '';
  };
  environment.etc."antimicrox/disable-controller.sh" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      exec ${pkgs.antimicrox}/bin/antimicrox --unload
    '';
  };

  environment.sessionVariables = { };

  environment.etc."profile.d/openai.sh".text = ''
    if [ -r /run/agenix/openai_api_key ]; then
      export OPENAI_API_KEY="$(cat /run/agenix/openai_api_key)"
    fi
  '';
  environment.etc."profile.d/openclaw.sh".text = ''
    if [ -r /run/agenix/openclaw_gateway_token ]; then
      export OPENCLAW_GATEWAY_TOKEN="$(cat /run/agenix/openclaw_gateway_token)"
    fi
  '';

  users.groups.libvirtd.members = [ "ltadeu6" ];

  users.users.ltadeu6 = {
    isNormalUser = true;
    description = "Lucas Tadeu";
    extraGroups = [
      "terraria"
      "mysql"
      "networkmanager"
      "wheel"
      "syncthing"
      "transmission"
      "storage"
    ];
    shell = pkgs.fish;
  };

  system.autoUpgrade = {
    enable = true;
    flake = "/home/ltadeu6/nixos-config";
    dates = "02:00";
    randomizedDelaySec = "45min";
    flags = [
      "--print-build-logs"
    ];
  };

  systemd.services."nix-flake-update" = {
    description = "Update flake.lock and commit";
    path = [ pkgs.git pkgs.nix pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      User = "ltadeu6";
      WorkingDirectory = "/home/ltadeu6/nixos-config";
      Environment = [
        "GIT_AUTHOR_NAME=auto-upgrade"
        "GIT_AUTHOR_EMAIL=auto-upgrade@localhost"
        "GIT_COMMITTER_NAME=auto-upgrade"
        "GIT_COMMITTER_EMAIL=auto-upgrade@localhost"
      ];
    };
    script = ''
      set -euo pipefail
      export PATH="${pkgs.git}/bin:${pkgs.nix}/bin:/run/current-system/sw/bin"

      repo_status="$(git status --porcelain=v1 --untracked-files=normal)"
      relevant_status="$(printf '%s\n' "$repo_status" | ${pkgs.gnugrep}/bin/grep -vE '^[ MARCUD?!]{2} flake\.lock$' || true)"
      if [ -n "$relevant_status" ]; then
        echo "Skipping flake update: repository has local changes"
        exit 0
      fi

      backup=""
      cleanup() {
        if [ -n "$backup" ] && [ -f "$backup" ] && [ ! -f flake.lock ]; then
          mv "$backup" flake.lock
        fi
      }
      trap cleanup EXIT

      if [ -f flake.lock ] && [ ! -w flake.lock ]; then
        backup="$(mktemp)"
        cp flake.lock "$backup"
        rm -f flake.lock
      fi

      /run/current-system/sw/bin/nix flake update --commit-lock-file

      if [ -n "$backup" ] && [ -f "$backup" ]; then
        rm -f "$backup"
      fi
      trap - EXIT
    '';
  };

  systemd.timers."nix-flake-update" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "02:00";
      RandomizedDelaySec = "45min";
      Persistent = true;
    };
  };

  systemd.services.flatpak-update = {
    description = "Update Flatpak apps";
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      ${pkgs.flatpak}/bin/flatpak update -y --noninteractive
    '';
  };

  systemd.timers.flatpak-update = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  nixpkgs.config.allowUnfree = true;

  # nixpkgs.config.cudaSupport = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;

  environment.systemPackages = with pkgs; [
    most
    agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    # mangohud
    hyfetch
    cacert
    fragments
    antimicrox
    kitty
    lutris
    protonup-qt
    protontricks
    hyprcursor
    dunst
    libnotify
    pulseaudio
    nautilus
    eog
    gnome-calculator
    qt6Packages.qtwayland
    glib
    gsettings-desktop-schemas
    wine
    wine64
    ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [ epkgs.vterm ]))
    libvterm
    (python3.withPackages (ps: with ps; [ requests ]))
    cmake
    gcc
    gnumake
    nodePackages.prettier
    nodePackages.pnpm
    fishPlugins.z
  ];

  # environment.loginShellInit = ''
  #   [[ "$(tty)" = "/dev/tty1" ]] && ./gs.sh
  # '';

  virtualisation.docker.enable = false;
  virtualisation.waydroid.enable = false;
  virtualisation.libvirtd.enable = true;
  # virtualisation.spiceUSBRedirection.enable = true;

  fonts.packages = with pkgs; [ nerd-fonts.fira-code nerd-fonts.gohufont ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  #   # wlr.enable = true;
  #   # config.common.default = [ "gtk" ];
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
