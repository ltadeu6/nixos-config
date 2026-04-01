# AGENTS.md

Instrucoes para agentes trabalhando neste repositorio.

## Escopo
- Este repo guarda configuracoes do NixOS e componentes relacionados.
- Priorize mudancas simples, pequenas e revisaveis.

## Estrutura
- `nixos/configuration.nix`: configuracao principal do sistema.
- `nixos/hardware-configuration.nix`: gerado pelo NixOS; edite somente se solicitado.
- `nixos/secrets.nix`: contem segredos; nao exibir nem registrar valores.
- `hypr/hyprland.conf`: configuracao do Hyprland.
- `hypr/hyprpaper.conf`: wallpaper do Hyprpaper.
- `doom/config.el`: configuracao do Doom Emacs (edite este arquivo).
- `doom/config.org`: atualmente nao esta funcionando; nao usar como fonte.
- `doom/init.el`: modulos do Doom Emacs.
- `doom/packages.el`: pacotes adicionais do Doom Emacs.
- `doom/custom.el`: customizacoes do Emacs (gerado).

## Boas praticas
- Evite alterar `hardware-configuration.nix` sem pedido explicito.
- Nao imprimir segredos, tokens ou chaves.
- Prefira blocos Nix claros e agrupados por topico.
- Ao adicionar servicos, habilite apenas o necessario.

## Aplicar mudancas
- Rebuild: `sudo nixos-rebuild switch`
- Validar sintaxe basica: `nix-instantiate --parse nixos/configuration.nix`

## Commits
- Use mensagens curtas e descritivas em ingles.
- Desative assinatura se o GPG falhar.
