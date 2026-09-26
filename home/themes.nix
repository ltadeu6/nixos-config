# Tema unico com troca em runtime (inspirado no theme switcher do Omarchy).
#
# Como funciona:
#   - Cada tema e um attrset de cores em `palettes`, dividido em `ui` (nomes
#     semanticos usados por waybar/wofi/Hyprland) e `term` (vocabulario ANSI
#     do kitty). Os dois conjuntos sao completos em todos os temas; nao ha
#     fallback silencioso.
#   - O Nix gera TODOS os temas de uma vez no store e o Home Manager publica
#     cada um em ~/.config/themes/<nome>/.
#   - Os apps nao leem o tema direto: leem ~/.config/current-theme, que e um
#     symlink. Trocar de tema e trocar o symlink e mandar reload -- sem
#     rebuild. E por isso que as cores saem dos configs e vao para ca.
#
# Para adicionar um tema: acrescente uma entrada em `palettes` com as mesmas
# chaves. Chave faltando quebra na avaliacao, nao em runtime.
{ config, lib, pkgs, ... }:

let
  themesDir = "${config.xdg.configHome}/themes";
  currentTheme = "${config.xdg.configHome}/current-theme";
  defaultTheme = "dracula";

  # Substitui @chave@ pelo valor. Usa replaceStrings em vez de replaceVars/
  # substituteAll para nao depender de API do nixpkgs que muda entre releases.
  renderTemplate = file: vars:
    builtins.replaceStrings (map (k: "@${k}@") (builtins.attrNames vars))
      (builtins.attrValues vars) (builtins.readFile file);

  # Hyprland quer rgba(rrggbbaa) sem '#'.
  toHyprColor = hex: "rgba(${lib.removePrefix "#" hex}ff)";

  palettes = {
    # Valores extraidos dos configs anteriores (configs/waybar/dracula.css e
    # programs.kitty). Waybar, kitty e bordas ficam identicos ao que era antes.
    # No wofi, dois tons proprios foram unificados com o resto da paleta:
    # o fundo do input/selecao era #44475a e virou surface1 (#494d64), e o
    # texto era #f8f8f2 e virou text (#f2f3f7). Diferenca minima, mas existe.
    dracula = {
      ui = {
        base = "#24273a";
        mantle = "#1e2030";
        crust = "#181926";
        text = "#f2f3f7";
        subtext0 = "#a5adcb";
        subtext1 = "#b8c0e0";
        surface0 = "#282A36";
        surface1 = "#494d64";
        surface2 = "#6272A4";
        overlay0 = "#6e738d";
        overlay1 = "#8087a2";
        overlay2 = "#939ab7";
        blue = "#8aadf4";
        lavender = "#b7bdf8";
        sapphire = "#7dc4e4";
        sky = "#91d7e3";
        teal = "#8BE9FD";
        green = "#50fa7E";
        yellow = "#f1fa8c";
        peach = "#f5a97f";
        maroon = "#ee99a0";
        red = "#ff5555";
        mauve = "#c6a0f6";
        purple = "#d6acff";
        pink = "#f5bde6";
        flamingo = "#f0c6c6";
        rosewater = "#f4dbd6";
        # Cores de janela do Hyprland: os valores que estavam hardcoded em
        # general { col.active_border / col.inactive_border }.
        borderActive = "#69ff94";
        borderInactive = "#6272A4";
      };
      term = {
        fg = "#f8f8f2";
        bg = "#282a36";
        selFg = "#ffffff";
        selBg = "#44475a";
        url = "#8be9fd";
        cursor = "#f8f8f2";
        tabActiveFg = "#282a36";
        tabActiveBg = "#f8f8f2";
        tabInactiveFg = "#282a36";
        tabInactiveBg = "#6272a4";
        mark1Fg = "#282a36";
        mark1Bg = "#ff5555";
        c0 = "#21222c";
        c8 = "#6272a4";
        c1 = "#ff5555";
        c9 = "#ff6e6e";
        c2 = "#50fa7b";
        c10 = "#69ff94";
        c3 = "#f1fa8c";
        c11 = "#ffffa5";
        c4 = "#bd93f9";
        c12 = "#d6acff";
        c5 = "#ff79c6";
        c13 = "#ff92df";
        c6 = "#8be9fd";
        c14 = "#a4ffff";
        c7 = "#f8f8f2";
        c15 = "#ffffff";
      };
    };

    # Segundo tema, para provar a troca. Os nomes de cor do dracula.css
    # antigo (base/mantle/crust/surface/overlay/lavender/rosewater) ja vinham
    # do vocabulario Catppuccin, entao Mocha preenche o schema inteiro sem
    # inventar valor nenhum.
    catppuccin-mocha = {
      ui = {
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
        text = "#cdd6f4";
        subtext0 = "#a6adc8";
        subtext1 = "#bac2de";
        surface0 = "#313244";
        surface1 = "#45475a";
        surface2 = "#585b70";
        overlay0 = "#6c7086";
        overlay1 = "#7f849c";
        overlay2 = "#9399b2";
        blue = "#89b4fa";
        lavender = "#b4befe";
        sapphire = "#74c7ec";
        sky = "#89dceb";
        teal = "#94e2d5";
        green = "#a6e3a1";
        yellow = "#f9e2af";
        peach = "#fab387";
        maroon = "#eba0ac";
        red = "#f38ba8";
        mauve = "#cba6f7";
        purple = "#cba6f7";
        pink = "#f5c2e7";
        flamingo = "#f2cdcd";
        rosewater = "#f5e0dc";
        borderActive = "#a6e3a1";
        borderInactive = "#585b70";
      };
      term = {
        fg = "#cdd6f4";
        bg = "#1e1e2e";
        selFg = "#1e1e2e";
        selBg = "#f5e0dc";
        url = "#89b4fa";
        cursor = "#f5e0dc";
        tabActiveFg = "#1e1e2e";
        tabActiveBg = "#cdd6f4";
        tabInactiveFg = "#1e1e2e";
        tabInactiveBg = "#585b70";
        mark1Fg = "#1e1e2e";
        mark1Bg = "#f38ba8";
        c0 = "#45475a";
        c8 = "#585b70";
        c1 = "#f38ba8";
        c9 = "#f38ba8";
        c2 = "#a6e3a1";
        c10 = "#a6e3a1";
        c3 = "#f9e2af";
        c11 = "#f9e2af";
        c4 = "#89b4fa";
        c12 = "#89b4fa";
        c5 = "#f5c2e7";
        c13 = "#f5c2e7";
        c6 = "#94e2d5";
        c14 = "#94e2d5";
        c7 = "#bac2de";
        c15 = "#a6adc8";
      };
    };
  };

  # --- geradores por app ---------------------------------------------------

  # GTK CSS: waybar importa isto e usa @teal, @red, @surface2 etc. O style.css
  # da waybar ja era todo por nome de cor, entao ele nao precisa de template.
  waybarColors = ui:
    lib.concatStringsSep "\n"
    (lib.mapAttrsToList (name: hex: "@define-color ${name} ${hex};") ui) + "\n";

  wofiStyle = ui: renderTemplate ../configs/wofi/style.css.in ui;

  hyprColors = ui: ''
    general {
        col.active_border = ${toHyprColor ui.borderActive}
        col.inactive_border = ${toHyprColor ui.borderInactive}
    }
  '';

  kittyColors = t: ''
    foreground ${t.fg}
    background ${t.bg}
    selection_foreground ${t.selFg}
    selection_background ${t.selBg}
    url_color ${t.url}
    cursor ${t.cursor}
    cursor_text_color background
    active_tab_foreground ${t.tabActiveFg}
    active_tab_background ${t.tabActiveBg}
    inactive_tab_foreground ${t.tabInactiveFg}
    inactive_tab_background ${t.tabInactiveBg}
    mark1_foreground ${t.mark1Fg}
    mark1_background ${t.mark1Bg}
    color0 ${t.c0}
    color8 ${t.c8}
    color1 ${t.c1}
    color9 ${t.c9}
    color2 ${t.c2}
    color10 ${t.c10}
    color3 ${t.c3}
    color11 ${t.c11}
    color4 ${t.c4}
    color12 ${t.c12}
    color5 ${t.c5}
    color13 ${t.c13}
    color6 ${t.c6}
    color14 ${t.c14}
    color7 ${t.c7}
    color15 ${t.c15}
  '';

  mkTheme = name: p:
    pkgs.linkFarm "theme-${name}" {
      "waybar-colors.css" =
        pkgs.writeText "${name}-waybar-colors.css" (waybarColors p.ui);
      "wofi-style.css" = pkgs.writeText "${name}-wofi-style.css" (wofiStyle p.ui);
      "hypr-colors.conf" =
        pkgs.writeText "${name}-hypr-colors.conf" (hyprColors p.ui);
      "kitty-colors.conf" =
        pkgs.writeText "${name}-kitty-colors.conf" (kittyColors p.term);
    };

  themeNames = builtins.attrNames palettes;

  # --- switcher de runtime -------------------------------------------------

  themeSwitch = pkgs.writeShellApplication {
    name = "theme-switch";
    runtimeInputs = with pkgs; [ coreutils wofi libnotify procps hyprland ];
    text = ''
      themes_dir=${lib.escapeShellArg themesDir}
      current=${lib.escapeShellArg currentTheme}
      available=${lib.escapeShellArg (lib.concatStringsSep "\n" themeNames)}

      name="''${1:-}"

      # Sem argumento: abre o mesmo wofi do launcher como seletor.
      if [ -z "$name" ]; then
        name="$(printf '%s\n' "$available" | wofi --dmenu --prompt 'Tema...')" || exit 0
      fi
      [ -n "$name" ] || exit 0

      if [ ! -d "$themes_dir/$name" ]; then
        echo "tema desconhecido: $name" >&2
        echo "disponiveis:" >&2
        printf '  %s\n' "$available" >&2
        exit 1
      fi

      ln -sfn "$themes_dir/$name" "$current"

      # Reloads: cada app tem seu proprio mecanismo e nenhum precisa reiniciar.
      # O `|| true` e proposital -- app fechado nao e erro de troca de tema.
      pkill -SIGUSR2 waybar || true   # waybar: recarrega CSS
      pkill -SIGUSR1 kitty  || true   # kitty: recarrega kitty.conf
      hyprctl reload >/dev/null 2>&1 || true

      notify-send -a theme-switch "Tema: $name" "Waybar, kitty, wofi e bordas atualizados."
    '';
  };

  themeCurrent = pkgs.writeShellApplication {
    name = "theme-current";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''
      # readlink sem -f de proposito: -f resolve a cadeia inteira ate o
      # /nix/store e imprimiria "<hash>-theme-dracula" em vez de "dracula".
      basename "$(readlink ${lib.escapeShellArg currentTheme})"
    '';
  };

in {
  home.packages = [ themeSwitch themeCurrent ];

  # Publica todos os temas: ~/.config/themes/<nome>/{waybar-colors.css,...}
  home.file = lib.listToAttrs (map (name: {
    name = ".config/themes/${name}";
    value = { source = mkTheme name palettes.${name}; };
  }) themeNames);

  # O symlink e estado de runtime, nao pode ser gerenciado pelo Home Manager
  # (senao a troca seria desfeita no proximo switch). Criado so se faltar.
  #
  # O reload no fim garante que a ativacao termine com a sessao consistente:
  # waybar e kitty seguem com o CSS/conf que leram ao iniciar, e o Hyprland
  # precisa reler o `source` do tema. Tudo com `|| true` porque ativacao fora
  # de sessao grafica e normal.
  home.activation.currentThemeDefault =
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      if [ ! -e ${lib.escapeShellArg currentTheme} ]; then
        run ln -sfn ${lib.escapeShellArg "${themesDir}/${defaultTheme}"} \
          ${lib.escapeShellArg currentTheme}
      fi

      run ${pkgs.procps}/bin/pkill -SIGUSR2 waybar || true
      run ${pkgs.procps}/bin/pkill -SIGUSR1 kitty || true
      run ${pkgs.hyprland}/bin/hyprctl reload > /dev/null 2>&1 || true
    '';
}
