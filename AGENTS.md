# AGENTS.md

Instrucoes para agentes trabalhando neste repositorio.

## Escopo
- Este repo guarda configuracoes do NixOS e componentes relacionados.
- Priorize mudancas simples, pequenas e revisaveis.

## Estrutura
- `hosts/Nixos/configuration.nix`: configuracao principal do sistema.
- `hosts/Nixos/hardware-configuration.nix`: gerado pelo NixOS; edite somente se solicitado.
- `nixos/secrets.nix`: legado (nao usado mais).
- `secrets/secrets.nix`: regras do agenix (sem segredos em texto puro).
- `configs/hypr/hyprland.conf`: configuracao do Hyprland.
- `configs/hypr/hyprpaper.conf`: wallpaper do Hyprpaper.
- `configs/doom/config.el`: configuracao do Doom Emacs (edite este arquivo).
- `configs/doom/config.org`: atualmente nao esta funcionando; nao usar como fonte.
- `configs/doom/init.el`: modulos do Doom Emacs.
- `configs/doom/packages.el`: pacotes adicionais do Doom Emacs.
- `configs/doom/custom.el`: customizacoes do Emacs (gerado).

## Boas praticas
- Evite alterar `hardware-configuration.nix` sem pedido explicito.
- Nao imprimir segredos, tokens ou chaves.
- Prefira blocos Nix claros e agrupados por topico.
- Ao adicionar servicos, habilite apenas o necessario.

## Waybar (AC)
- `configs/waybar/air_control.py` usa apenas stdlib (`urllib`) para falar com o Home Assistant.
- Alteracoes de setpoint/modo/fan sao imediatas na UI, com envio real atrasado (debounce) via arquivos em `~/.cache/`.
- `fan_only` e `dry` mostram sempre a temperatura atual (room) no display.
- Indicador pequeno de fan speed aparece como subscrito ao lado do icone.
- `configs/waybar/config` (modulo `custom/ac`): clique alterna on/off, clique direito cicla modos (sem `off`), clique do meio cicla fan; `interval` esta em 3s.

## Aplicar mudancas
- Rebuild: `sudo nixos-rebuild switch --flake .#Nixos`
- Validar sintaxe basica: `nix-instantiate --parse hosts/Nixos/configuration.nix`

## Commits
- Use mensagens curtas e descritivas em ingles.
- Desative assinatura se o GPG falhar.
