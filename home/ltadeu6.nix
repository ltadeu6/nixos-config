{ config, pkgs, ... }:

{
  home.username = "ltadeu6";
  home.homeDirectory = "/home/ltadeu6";
  home.stateVersion = "25.11";

  home.sessionVariables = {
    MANPAGER = "most";
    fish_greeting = "";
    XCURSOR_THEME = "Breeze";
    XCURSOR_SIZE = "30";
    HYPRCURSOR_THEME = "Breeze";
    HYPRCURSOR_SIZE = "30";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };

  home.packages = with pkgs; [
    tor-browser
    texlive.combined.scheme-full
    foliate
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
    ".config/fish/conf.d/agenix-openai.fish".text = ''
      if test -r /run/agenix/openai_api_key
        set -gx OPENAI_API_KEY (cat /run/agenix/openai_api_key)
      end
    '';

    ".config/hypr/hyprland.conf".source = ../configs/hypr/hyprland.conf;
    ".config/hypr/hyprpaper.conf".source = ../configs/hypr/hyprpaper.conf;

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
  };

  programs.home-manager.enable = true;
}
