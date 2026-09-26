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

  themesDir = "${config.xdg.configHome}/themes";
  currentTheme = "${config.xdg.configHome}/current-theme";
  defaultTheme = "dracula";

  renderTemplate = file: vars:
    builtins.replaceStrings (map (k: "@${k}@") (builtins.attrNames vars))
      (builtins.attrValues vars) (builtins.readFile file);

  toHyprColor = hex: "rgba(${lib.removePrefix "#" hex}ff)";

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
      # Registra se o tema e claro ou escuro; usado por quem precisar decidir
      # variante (GTK, por exemplo) e util para depurar.
      "mode" = pkgs.writeText "${name}-mode" "${p.mode}\n";
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

      notify-send -a theme-switch "Tema: $name" \
        "Waybar, kitty, wofi e bordas atualizados."
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
