# Tema unico com troca em runtime (inspirado no theme switcher do Omarchy).
#
# Como funciona:
#   - As paletas vivem em ./palettes.nix, no vocabulario do proprio Omarchy
#     (accent / selection / muted / *_background / *_foreground / cores). Isso
#     e deliberado: reimportar temas de la vira copia de arquivo, nao traducao.
#   - Este modulo mapeia esse vocabulario para o que cada app precisa. O mapa
#     esta em `roles` abaixo e e a unica coisa a mexer se um app passar a usar
#     uma cor nova.
#   - O Nix gera TODOS os temas de uma vez no store e o Home Manager publica
#     cada um em ~/.config/themes/<nome>/.
#   - Os apps nao leem o tema direto: leem ~/.config/current-theme, que e um
#     symlink. Trocar de tema e trocar o symlink e mandar reload -- sem
#     rebuild.
#
# Cuidado com caminhos: o `source` do Hyprland e o `@import` do wofi precisam
# ser ABSOLUTOS (motivos documentados em configs/hypr/hyprland.conf e no
# home.file do wofi). A waybar e a excecao em que o relativo funciona.
{ config, lib, pkgs, ... }:

let
  palettes = import ./palettes.nix;
  wallpapers = import ./wallpapers.nix { inherit (pkgs) fetchurl; };

  # `dracula` nao tem wallpaper do Omarchy: fica com o do usuario.
  wallpaperFor = name:
    wallpapers.${name} or {
      ext = "png";
      file = ../configs/hypr/nixos.png;
    };

  themesDir = "${config.xdg.configHome}/themes";
  currentTheme = "${config.xdg.configHome}/current-theme";
  defaultTheme = "dracula";

  renderTemplate = file: vars:
    builtins.replaceStrings (map (k: "@${k}@") (builtins.attrNames vars))
      (builtins.attrValues vars) (builtins.readFile file);

  # Os overrides de borda do Omarchy nem sempre sao hex: alguns temas trazem a
  # expressao de cor do Hyprland pronta, inclusive gradiente
  # ("rgba(26a269ee) rgba(2ec27eee) 45deg") ou "rgb(1e1e1e)". Envolver isso em
  # rgba(...) gera "rgba(rgba(...)ff)", que o Hyprland rejeita em silencio e
  # cai na borda branca default. So hex ganha o wrapper.
  toHyprColor = v:
    if lib.hasPrefix "#" v then
      "rgba(${lib.removePrefix "#" v}ff)"
    else
      v;

  # --- mapa de papeis ------------------------------------------------------
  # Traduz a paleta do Omarchy para os nomes que os configs dos apps usam.
  # `orange`/`brown` faltam em alguns temas e os overrides de borda existem em
  # poucos, dai os fallbacks com `or`.
  roles = p: rec {
    # Nomes consumidos por configs/waybar/style.css e configs/wofi/style.css.in
    text = p.bright_foreground;
    surface0 = p.background;
    surface1 = p.selection;
    surface2 = p.muted;
    teal = p.accent; # accent principal: workspaces, icones ativos
    red = p.red;
    green = p.green;
    yellow = p.yellow;
    lavender = p.light_foreground; # borda da pilula do relogio

    borderActive = p.hyprland_active_border or p.accent;
    borderInactive = p.hyprland_inactive_border or p.muted;
  };

  # --- geradores por app ---------------------------------------------------

  waybarKeys = [
    "text"
    "surface0"
    "surface1"
    "surface2"
    "teal"
    "red"
    "green"
    "yellow"
    "lavender"
  ];

  waybarColors = r:
    lib.concatStringsSep "\n"
    (map (k: "@define-color ${k} ${r.${k}};") waybarKeys) + "\n";

  wofiStyle = r:
    renderTemplate ../configs/wofi/style.css.in {
      inherit (r) text surface0 surface1 teal;
    };

  hyprColors = r: ''
    general {
        col.active_border = ${toHyprColor r.borderActive}
        col.inactive_border = ${toHyprColor r.borderInactive}
    }
  '';

  # dunst nao tem `include`, mas le drop-ins de ~/.config/dunst/dunstrc.d/*.conf
  # depois do dunstrc principal -- por isso o tema entra por la e ganha do que
  # estiver no dunstrc gerado pelo Home Manager.
  dunstColors = p: ''
    [global]
        frame_color = "${p.accent}"
        background = "${p.darker_background}"
        foreground = "${p.bright_foreground}"
  '';

  # ANSI do kitty a partir da paleta: preto = fundo escuro, branco = foreground,
  # e os brilhantes nos slots 8-15 como manda o padrao.
  kittyColors = p: ''
    foreground ${p.foreground}
    background ${p.background}
    selection_foreground ${p.bright_foreground}
    selection_background ${p.selection}
    url_color ${p.accent}
    cursor ${p.foreground}
    cursor_text_color background
    active_tab_foreground ${p.background}
    active_tab_background ${p.active_tab_background or p.foreground}
    inactive_tab_foreground ${p.background}
    inactive_tab_background ${p.muted}
    mark1_foreground ${p.background}
    mark1_background ${p.red}
    color0 ${p.dark_background}
    color8 ${p.muted}
    color1 ${p.red}
    color9 ${p.bright_red}
    color2 ${p.green}
    color10 ${p.bright_green}
    color3 ${p.yellow}
    color11 ${p.bright_yellow}
    color4 ${p.blue}
    color12 ${p.bright_blue}
    color5 ${p.magenta}
    color13 ${p.bright_magenta}
    color6 ${p.cyan}
    color14 ${p.bright_cyan}
    color7 ${p.foreground}
    color15 ${p.bright_foreground}
  '';

  # Tema Doom gerado a partir da paleta. Mapear os 23 temas para os ~70 temas
  # prontos do doom-themes daria combinacoes ruins (nao existe catppuccin,
  # everforest nem kanagawa la), enquanto `def-doom-theme` precisa exatamente
  # das cores que a paleta ja tem. O nome do tema e sempre `doom-omarchy`: o
  # arquivo muda por tema, o simbolo nao, entao o config.el nao precisa saber
  # qual tema esta ativo.
  #
  # As triplas sao (grafico, 256 cores, 16 cores); so a primeira importa aqui.
  doomTheme = p:
    let
      # String Nix normal (nao indentada) para poder escrever o quote da lista
      # elisp sem colidir com o delimitador . Sem o quote, `("#hex" ...)`
      # seria avaliado como chamada de funcao. Aspas duplas porque em elisp
      # `'#282a36` seria quote de simbolo, nao string.
      c = hex: "'(\"${hex}\" \"${hex}\" \"white\")";
      orange = p.orange or p.yellow;
    in ''
      ;;; doom-omarchy-theme.el --- gerado por home/themes.nix -*- lexical-binding: t; no-byte-compile: t; -*-
      ;;; Commentary:
      ;;; NAO EDITE. Gerado a partir da paleta do tema atual.
      ;;; Code:

      (require 'doom-themes)

      (def-doom-theme doom-omarchy
        "Tema gerado a partir da paleta do tema ativo do sistema."

        ((bg         ${c p.background})
         (bg-alt     ${c p.dark_background})
         (base0      ${c p.darker_background})
         (base1      ${c p.dark_background})
         (base2      ${c p.lighter_background})
         (base3      ${c p.selection})
         (base4      ${c p.muted})
         (base5      ${c p.dark_foreground})
         (base6      ${c p.foreground})
         (base7      ${c p.light_foreground})
         (base8      ${c p.bright_foreground})
         (fg         ${c p.foreground})
         (fg-alt     ${c p.light_foreground})

         (grey       base4)
         (red        ${c p.red})
         (orange     ${c orange})
         (green      ${c p.green})
         (teal       ${c p.bright_cyan})
         (yellow     ${c p.yellow})
         (blue       ${c p.blue})
         (dark-blue  ${c p.bright_blue})
         (magenta    ${c p.magenta})
         (violet     ${c p.bright_magenta})
         (cyan       ${c p.cyan})
         (dark-cyan  ${c p.bright_cyan})

         ;; categorias obrigatorias
         (accent         ${c p.accent})
         (highlight      accent)
         (vertical-bar   (doom-darken base1 0.1))
         (selection      base3)
         (builtin        orange)
         (comments       base5)
         (doc-comments   (doom-lighten base5 0.25))
         (constants      cyan)
         (functions      green)
         (keywords       magenta)
         (methods        teal)
         (operators      violet)
         (type           violet)
         (strings        yellow)
         (variables      fg)
         (numbers        violet)
         (region         `(,(car base3) ,@(cdr base1)))
         (error          red)
         (warning        yellow)
         (success        green)
         (vc-modified    orange)
         (vc-added       green)
         (vc-deleted     red)

         (modeline-bg     base2)
         (modeline-bg-alt base1)
         (modeline-fg     fg)
         (modeline-fg-alt base5)))

      ;; Sem bloco de faces extra de proposito: doom-themes-base deriva todas
      ;; as faces da paleta acima, e a sintaxe `&override` falhou aqui com
      ;; "wrong-type-argument listp &override" nesta versao do doom-themes.

      (provide-theme 'doom-omarchy)
      ;;; doom-omarchy-theme.el ends here
    '';

  # Um hyprpaper.conf por tema. O hyprpaper 0.8 usa blocos `wallpaper {}` e
  # escolhe o decoder pela extensao do arquivo, e nesta versao (0.8.4) nao ha
  # request de IPC para trocar wallpaper -- todo `hyprctl hyprpaper ...` que
  # tentei respondeu "invalid hyprpaper request". Dai a abordagem: config por
  # tema e `hyprpaper --config`, reiniciando o processo na troca.
  hyprpaperConf = name: ''
    wallpaper {
      monitor =
      path = ${currentTheme}/wallpaper.${(wallpaperFor name).ext}
      fit_mode = cover
    }

    splash = false
  '';

  mkTheme = name: p:
    let r = roles p;
    in pkgs.linkFarm "theme-${name}" {
      "waybar-colors.css" =
        pkgs.writeText "${name}-waybar-colors.css" (waybarColors r);
      "wofi-style.css" = pkgs.writeText "${name}-wofi-style.css" (wofiStyle r);
      "hypr-colors.conf" =
        pkgs.writeText "${name}-hypr-colors.conf" (hyprColors r);
      "kitty-colors.conf" =
        pkgs.writeText "${name}-kitty-colors.conf" (kittyColors p);
      "dunst-colors.conf" =
        pkgs.writeText "${name}-dunst-colors.conf" (dunstColors p);
      # Nome fixo: `load-theme` procura <simbolo>-theme.el no
      # custom-theme-load-path, que o config.el aponta para o tema atual.
      "doom-omarchy-theme.el" =
        pkgs.writeText "${name}-doom-omarchy-theme.el" (doomTheme p);
      "wallpaper.${(wallpaperFor name).ext}" = (wallpaperFor name).file;
      "hyprpaper.conf" =
        pkgs.writeText "${name}-hyprpaper.conf" (hyprpaperConf name);
      # Registra se o tema e claro ou escuro; usado por quem precisar decidir
      # variante (GTK, por exemplo) e util para depurar.
      "mode" = pkgs.writeText "${name}-mode" "${p.mode}\n";
    };

  themeNames = builtins.attrNames palettes;

  # --- switcher de runtime -------------------------------------------------

  themeSwitch = pkgs.writeShellApplication {
    name = "theme-switch";
    runtimeInputs = with pkgs; [ coreutils wofi libnotify procps hyprland dunst emacs dconf ];
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

      # hyprpaper: sem IPC de troca nesta versao, entao reinicia apontando
      # para o config do tema. Piscada breve, e o preco de nao depender de
      # request que nao existe.
      if pgrep -x hyprpaper >/dev/null; then
        pkill -x hyprpaper || true
        setsid hyprpaper --config "$current/hyprpaper.conf" >/dev/null 2>&1 &
      fi
      dunstctl reload >/dev/null 2>&1 || true

      # GTK: os apps libadwaita/GTK4 leem color-scheme do dconf em runtime,
      # entao um tema claro deixa de vir com dialogos escuros. O `mode` de
      # cada tema esta no proprio diretorio do tema.
      # `dconf write` em vez de `gsettings set`: o gsettings exige o schema
      # org.gnome.desktop.interface no XDG_DATA_DIRS do processo e falhava com
      # "Nenhum esquema instalado" dentro deste script, sem que o `|| true`
      # deixasse isso aparecer. O dconf escreve a chave direto.
      #
      # Isso cobre apps GTK4/libadwaita, que leem a chave em runtime. Apps
      # GTK3 leem gtk-application-prefer-dark-theme do settings.ini, que e
      # estatico, e por isso nao acompanham a troca.
      if [ "$(cat "$current/mode" 2>/dev/null)" = "light" ]; then
        scheme=prefer-light
      else
        scheme=prefer-dark
      fi
      dconf write /org/gnome/desktop/interface/color-scheme "'$scheme'" || true

      # Emacs: reavalia o arquivo do tema (o simbolo e o mesmo, o conteudo
      # mudou) e aplica. Silencioso se nao houver daemon rodando.
      emacsclient --eval "(progn (load-file \"$current/doom-omarchy-theme.el\") (load-theme 'doom-omarchy t))" \
        >/dev/null 2>&1 || true

      # A notificacao vem depois do reload do dunst, senao ela mesma sai com a
      # moldura do tema anterior.
      notify-send -a theme-switch "Tema: $name" \
        "Waybar, kitty, wofi, dunst, Emacs, GTK, wallpaper e bordas atualizados."
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

  themeList = pkgs.writeShellApplication {
    name = "theme-list";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''
      current="$(basename "$(readlink ${lib.escapeShellArg currentTheme})")"
      for t in ${lib.concatStringsSep " " themeNames}; do
        if [ "$t" = "$current" ]; then echo "* $t"; else echo "  $t"; fi
      done
    '';
  };

in {
  home.packages = [ themeSwitch themeCurrent themeList ];

  # Publica todos os temas: ~/.config/themes/<nome>/{waybar-colors.css,...}
  home.file = lib.listToAttrs (map (name: {
    name = ".config/themes/${name}";
    value = { source = mkTheme name palettes.${name}; };
  }) themeNames) // {
    # Symlink FORA do store: precisa apontar para o caminho do tema atual e
    # ser resolvido pelo dunst na leitura, nao congelado no store em build
    # time. Prefixo 50- para ordenar depois do dunstrc principal.
    ".config/dunst/dunstrc.d/50-theme.conf".source =
      config.lib.file.mkOutOfStoreSymlink
      "${currentTheme}/dunst-colors.conf";
  };

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

      # hyprpaper segue rodando com o config que leu ao iniciar (que pode nem
      # existir mais depois desta ativacao), entao reinicia apontando para o
      # tema atual. Sem isso, o wallpaper so troca no proximo theme-switch.
      if ${pkgs.procps}/bin/pgrep -x hyprpaper > /dev/null; then
        run ${pkgs.procps}/bin/pkill -x hyprpaper || true
        run setsid ${pkgs.hyprpaper}/bin/hyprpaper --config \
          ${lib.escapeShellArg "${currentTheme}/hyprpaper.conf"} \
          > /dev/null 2>&1 &
      fi
    '';
}
