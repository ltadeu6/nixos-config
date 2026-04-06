{ config, pkgs, lib, ... }:

{
  home.username = "ltadeu6";
  home.homeDirectory = "/home/ltadeu6";
  home.stateVersion = "25.11";

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "FiraCode Nerd Font Mono";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      font_size = 16.0;
      disable_ligatures = "cursor";
      copy_on_select = "yes";
      strip_trailing_spaces = "smart";
      enable_audio_bell = "no";
      remember_window_size = "no";
      initial_window_width = 900;
      initial_window_height = 500;
      window_padding_width = 15.0;
      confirm_os_window_close = 0;
      background_opacity = 1;
      dynamic_background_opacity = "yes";
      foreground = "#f8f8f2";
      background = "#282a36";
      selection_foreground = "#ffffff";
      selection_background = "#44475a";
      url_color = "#8be9fd";
      color0 = "#21222c";
      color8 = "#6272a4";
      color1 = "#ff5555";
      color9 = "#ff6e6e";
      color2 = "#50fa7b";
      color10 = "#69ff94";
      color3 = "#f1fa8c";
      color11 = "#ffffa5";
      color4 = "#bd93f9";
      color12 = "#d6acff";
      color5 = "#ff79c6";
      color13 = "#ff92df";
      color6 = "#8be9fd";
      color14 = "#a4ffff";
      color7 = "#f8f8f2";
      color15 = "#ffffff";
      cursor = "#f8f8f2";
      cursor_text_color = "background";
      active_tab_foreground = "#282a36";
      active_tab_background = "#f8f8f2";
      inactive_tab_foreground = "#282a36";
      inactive_tab_background = "#6272a4";
      mark1_foreground = "#282a36";
      mark1_background = "#ff5555";
      shell = "fish";
      editor = "nvim";
      close_on_child_death = "yes";
      term = "xterm-kitty";
    };
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "none";
        width = "(400, 700)";
        height = 300;
        origin = "bottom-right";
        offset = "20x20";
        scale = 0;
        notification_limit = 20;
        progress_bar = false;
        icon_corner_radius = 12;
        icon_corners = "all";
        indicate_hidden = true;
        transparency = 20;
        separator_height = 2;
        padding = 15;
        horizontal_padding = 15;
        text_icon_padding = 15;
        frame_width = 3;
        frame_color = "#ff2e97";
        background = "#0c0a20";
        foreground = "#f2f3f7";
        gap_size = 0;
        separator_color = "frame";
        sort = true;
        font = "GohuFont 14 Nerd Font Mono";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
        enable_recursive_icon_lookup = true;
        icon_theme = "Papirus";
        icon_position = "left";
        min_icon_size = 48;
        max_icon_size = 64;
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    font = {
      name = "Sans";
      size = 10;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-toolbar-style = "GTK_TOOLBAR_ICONS";
      gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
      gtk-button-images = 0;
      gtk-menu-images = 0;
      gtk-enable-event-sounds = 1;
      gtk-enable-input-feedback-sounds = 0;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintmedium";
      gtk-xft-rgba = "rgb";
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Breeze";
    package = pkgs.kdePackages.breeze;
    size = 30;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/discord-402572971681644545" = [ "discord-402572971681644545.desktop" ];
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "x-scheme-handler/magnet" = [ "userapp-transmission-gtk-B3E3L2.desktop" ];
      "x-scheme-handler/http" = [ "app.zen_browser.zen.desktop" ];
      "x-scheme-handler/https" = [ "app.zen_browser.zen.desktop" ];
      "x-scheme-handler/chrome" = [ "app.zen_browser.zen.desktop" ];
      "text/html" = [ "app.zen_browser.zen.desktop" ];
      "application/x-extension-htm" = [ "app.zen_browser.zen.desktop" ];
      "application/x-extension-html" = [ "app.zen_browser.zen.desktop" ];
      "application/x-extension-shtml" = [ "app.zen_browser.zen.desktop" ];
      "application/xhtml+xml" = [ "app.zen_browser.zen.desktop" ];
      "application/x-extension-xhtml" = [ "app.zen_browser.zen.desktop" ];
      "application/x-extension-xht" = [ "app.zen_browser.zen.desktop" ];
      "image/png" = [ "org.gnome.eog.desktop" ];
      "image/svg+xml" = [ "org.inkscape.Inkscape.desktop" ];
      "image/jpeg" = [ "org.gnome.eog.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
    };
    associations.added = {
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "x-scheme-handler/magnet" = [ "userapp-transmission-gtk-B3E3L2.desktop" ];
      "x-scheme-handler/http" = [ "app.zen_browser.zen.desktop" ];
      "x-scheme-handler/https" = [ "app.zen_browser.zen.desktop" ];
      "x-scheme-handler/chrome" = [ "app.zen_browser.zen.desktop" ];
      "text/html" = [ "app.zen_browser.zen.desktop" ];
      "application/x-extension-htm" = [ "app.zen_browser.zen.desktop" ];
      "application/x-extension-html" = [ "app.zen_browser.zen.desktop" ];
      "application/x-extension-shtml" = [ "app.zen_browser.zen.desktop" ];
      "application/xhtml+xml" = [ "app.zen_browser.zen.desktop" ];
      "application/x-extension-xhtml" = [ "app.zen_browser.zen.desktop" ];
      "application/x-extension-xht" = [ "app.zen_browser.zen.desktop" ];
      "image/png" = [ "org.gnome.eog.desktop" ];
      "application/x-partial-download" = [ "mpv.desktop" ];
      "image/svg+xml" = [ "org.inkscape.Inkscape.desktop" ];
      "text/plain" = [ "emacs.desktop" ];
      "image/jpeg" = [ "org.gnome.eog.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "$HOME/Área de trabalho";
    download = "$HOME/Downloads";
    templates = "$HOME/Modelos";
    publicShare = "$HOME/Público";
    documents = "$HOME/Documentos";
    music = "$HOME/Músicas";
    pictures = "$HOME/Imagens";
    videos = "$HOME/Vídeos";
  };

  home.sessionVariables = {
    MANPAGER = "most";
    HYPRCURSOR_THEME = "Breeze";
    HYPRCURSOR_SIZE = "30";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };

  home.packages = with pkgs; [
    tor-browser
    texlive.combined.scheme-full
    foliate
    waybar
    hyprpaper
    sshfs
    papirus-icon-theme
    trash-cli
    libreoffice
    eza
    wofi
    killall
    python3
    python3Packages.requests
    cmake
    gnumake
    ripgrep
    fd
    ffmpeg
    nixfmt-classic
    editorconfig-core-c
    man
    hyprpicker
    networkmanager
    prismlauncher
    gimp
    inkscape
    blender
    discord-ptb
    vscode
    direnv
    unzip
    codex
    zip
    file-roller
    clang-tools
    libxml2
    gdtoolkit_4
    bat
    alpaca
    ispell
    cartridges
    libvterm
    libgccjit
    pavucontrol
    playerctl
    mpv
    tenacity
    gnome-connections
    jsbeautifier
    tmux
    stylelint
    html-tidy
    shfmt
    shellcheck
    black
    isort
    pipenv
    jq
    wl-clipboard
    nodejs
    texlab
    gnome-boxes
    android-studio
    sageWithDoc
    evince
    poppler-utils
  ];

  home.file = {
    ".config/hypr/hyprland.conf".source = ../configs/hypr/hyprland.conf;
    ".config/hypr/hyprpaper.conf".source = ../configs/hypr/hyprpaper.conf;

    ".config/hyfetch.json".text = builtins.toJSON {
      preset = "voidgirl";
      mode = "rgb";
      light_dark = "dark";
      lightness = 0.65;
      color_align = {
        mode = "custom";
        custom_colors = {
          "1" = 2;
          "2" = 0;
        };
        fore_back = [ ];
      };
      backend = "neofetch";
      args = null;
      distro = null;
      pride_month_shown = [ ];
      pride_month_disable = false;
    };

    ".config/waybar/config".source = ../configs/waybar/config;
    ".config/waybar/style.css".source = ../configs/waybar/style.css;
    ".config/waybar/dracula.css".source = ../configs/waybar/dracula.css;

    ".config/waybar/air_control.py" = {
      source = ../configs/waybar/air_control.py;
      executable = true;
    };
    ".config/waybar/launch.sh" = {
      source = ../configs/waybar/launch.sh;
      executable = true;
    };
    ".config/waybar/switch_sink.sh" = {
      source = ../configs/waybar/switch_sink.sh;
      executable = true;
    };

    ".config/doom/config.el".source = ../configs/doom/config.el;
    ".config/doom/init.el".source = ../configs/doom/init.el;
    ".config/doom/packages.el".source = ../configs/doom/packages.el;

    ".config/wofi/config".source = ../configs/wofi/config;
    ".config/wofi/style.css".source = ../configs/wofi/style.css;
    ".config/wofi/menu".source = ../configs/wofi/menu;
    ".config/wofi/menu.css".source = ../configs/wofi/menu.css;
  };

  programs.openclaw = {
    enable = true;
    documents = ../openclaw/documents;
    instances.default = {
      enable = true;
      config = {
        gateway.mode = "local";
        gateway.auth.mode = "token";
        gateway.auth.token = {
          source = "env";
          provider = "default";
          id = "OPENCLAW_GATEWAY_TOKEN";
        };
        gateway.remote.token = {
          source = "env";
          provider = "default";
          id = "OPENCLAW_GATEWAY_TOKEN";
        };

        agents.defaults.model.primary = "ollama/qwen2.5:3b";
        models.providers.ollama = {
          baseUrl = "http://127.0.0.1:11434";
          api = "ollama";
          apiKey = "ollama-local";
          models = [ ];
        };
      };
    };
  };

  home.activation.openclawGatewayEnv = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    token_file="/run/agenix/openclaw_gateway_token"
    env_file="$HOME/.config/openclaw/gateway.env"
    if [ -r "$token_file" ]; then
      mkdir -p "$(dirname "$env_file")"
      umask 177
      printf 'OPENCLAW_GATEWAY_TOKEN=%s\n' "$(cat "$token_file")" > "$env_file"
    fi
  '';

  systemd.user.services.openclaw-gateway = {
    Service.EnvironmentFile =
      "${config.home.homeDirectory}/.config/openclaw/gateway.env";
    Install.WantedBy = [ "default.target" ];
  };

  home.file.".openclaw/openclaw.json".force = true;

  programs.home-manager.enable = true;
}
