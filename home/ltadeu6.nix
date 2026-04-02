{ config, pkgs, ... }:

{
  home.username = "ltadeu6";
  home.homeDirectory = "/home/ltadeu6";
  home.stateVersion = "25.11";

  home.sessionVariables = {
    MANPAGER = "most";
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
    ".config/kitty/kitty.conf".source = ../configs/kitty/kitty.conf;
    ".config/kitty/colors-kitty.conf".source = ../configs/kitty/colors-kitty.conf;

    ".config/dunst/dunstrc".source = ../configs/dunst/dunstrc;

    ".config/hypr/hyprland.conf".source = ../configs/hypr/hyprland.conf;
    ".config/hypr/hyprpaper.conf".source = ../configs/hypr/hyprpaper.conf;

    ".config/hyfetch.json".source = ../configs/hyfetch/hyfetch.json;

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

  programs.home-manager.enable = true;
}
