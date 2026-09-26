# GERADO -- nao edite a mao.
#
# Um wallpaper por tema, dos backgrounds do Omarchy
# (github.com/omacom/omarchy, branch quattro, themes/<nome>/backgrounds/).
# Escolha deterministica: o arquivo de menor numero que nao seja o
# `omarchy.*` (arte generica), caindo para ele quando e o unico.
#
# Baixado e verificado pelo Nix, nao versionado -- sao ~19 MB que nao
# precisam entrar no git. `dracula` nao aparece aqui de proposito: mantem o
# configs/hypr/nixos.png, que e escolha do usuario.
#
# `ext` e obrigatorio e nao decorativo: o hyprpaper escolhe o decoder pela
# extensao do arquivo, entao o nome publicado tem que preserva-la.
{ fetchurl }:
{
  "catppuccin-latte" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/catppuccin-latte/backgrounds/1-color-fade.webp";
      sha256 = "00v6sfzy0bpqabynb1y94j8ic0zvdkxynvpg63k88fbif0bj3jy4";
      name = "wallpaper-catppuccin-latte-1-color-fade.webp";
    };
  };
  "catppuccin" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/catppuccin/backgrounds/1-totoro.webp";
      sha256 = "1di4yybbw8cm0fs4s1jn93xak4cm2sw8vppfa9z6n0fk1ridm5j8";
      name = "wallpaper-catppuccin-1-totoro.webp";
    };
  };
  "ethereal" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/ethereal/backgrounds/1-cosmic.webp";
      sha256 = "0qxbvmx5hqclqj1lvbff0rxcwrab3r04dxxxwidc4p5ssh3ia973";
      name = "wallpaper-ethereal-1-cosmic.webp";
    };
  };
  "everforest" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/everforest/backgrounds/1-tree-tops.webp";
      sha256 = "0y125fzp2v6245rivaw2nx5xk86c91nnjzxl918ycxmrrwmpaq13";
      name = "wallpaper-everforest-1-tree-tops.webp";
    };
  };
  "flexoki-light" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/flexoki-light/backgrounds/1-orb.webp";
      sha256 = "03z97raxcdq5l5wnr1iq6s0ykf22asz980xvbjhz35bs5vzw3y1p";
      name = "wallpaper-flexoki-light-1-orb.webp";
    };
  };
  "gruvbox" = {
    ext = "jpg";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/gruvbox/backgrounds/1-the-backwater.jpg";
      sha256 = "1imaxha4vf98n5njlwg9pw7vpzm0aqdzh3w2ib089y8a6ypcdkqk";
      name = "wallpaper-gruvbox-1-the-backwater.jpg";
    };
  };
  "hackerman" = {
    ext = "jpg";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/hackerman/backgrounds/1-synth-scape.jpg";
      sha256 = "0zipgbr9g17hm697mrfq7wfirsl94fhygps33ggy017j6m4mkln7";
      name = "wallpaper-hackerman-1-synth-scape.jpg";
    };
  };
  "kanagawa" = {
    ext = "jpg";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/kanagawa/backgrounds/1-kanagawa.jpg";
      sha256 = "0zdji2gmrh7glh18m4flnp5w6f98k5hvc0vnp06rylw8frqpv0cv";
      name = "wallpaper-kanagawa-1-kanagawa.jpg";
    };
  };
  "last-horizon" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/last-horizon/backgrounds/1-eyes-wide.webp";
      sha256 = "1m3va8z4m8fx08g1miajbb6zs7c4769wrcyjfxfl6xdx4pm2xk2k";
      name = "wallpaper-last-horizon-1-eyes-wide.webp";
    };
  };
  "lumon" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/lumon/backgrounds/01-united-in-severance.webp";
      sha256 = "19bka2mphq049hclfn8c45563qy4nqi8ib3k59gysxr0n963vyyd";
      name = "wallpaper-lumon-01-united-in-severance.webp";
    };
  };
  "lupine" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/lupine/backgrounds/01-cherry-blossom-bokeh.webp";
      sha256 = "0si9r7kxdqzna0f2y7hbr24zd8cck04ymg0ynfmbbyl54szlmbcr";
      name = "wallpaper-lupine-01-cherry-blossom-bokeh.webp";
    };
  };
  "matte-black" = {
    ext = "jpg";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/matte-black/backgrounds/0-ship-at-sea.jpg";
      sha256 = "1b1rw0pwx2lv97d9k5w70j7r6yg6in6s49mq0a8qmyykvwd6kyjm";
      name = "wallpaper-matte-black-0-ship-at-sea.jpg";
    };
  };
  "miasma" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/miasma/backgrounds/01-nature-of-fear.webp";
      sha256 = "1920ap007kgdi79dgcf17ylgrw25mdhl93bkzwz9xsly7a3g5icb";
      name = "wallpaper-miasma-01-nature-of-fear.webp";
    };
  };
  "nord" = {
    ext = "jpg";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/nord/backgrounds/0-black-moon.jpg";
      sha256 = "10gziqsr1bks55f6xxgcccg26vgb0kcdhk890jba7ffbskvznwv8";
      name = "wallpaper-nord-0-black-moon.jpg";
    };
  };
  "osaka-jade" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/osaka-jade/backgrounds/1-glowing-city.webp";
      sha256 = "0ijrib7c8k1cfw10w4248gzmq2pdyyb67ipwql3s6pf6r2kw8d6j";
      name = "wallpaper-osaka-jade-1-glowing-city.webp";
    };
  };
  "retro-82" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/retro-82/backgrounds/1-in-the-groove.webp";
      sha256 = "12ldfxa11lcdpmb8nknn16ymf646q6zipfn3dw6kf460f3gyznf9";
      name = "wallpaper-retro-82-1-in-the-groove.webp";
    };
  };
  "ristretto" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/ristretto/backgrounds/0-launch.webp";
      sha256 = "0i2hk2ms0vidbbnhlsbrww136vicragjq5f0x1hn7wybwnzsgls2";
      name = "wallpaper-ristretto-0-launch.webp";
    };
  };
  "rose-pine" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/rose-pine/backgrounds/1-funky-shapes.webp";
      sha256 = "109bkwrq9r64zf7r8qhqn3a91mdplixfh869m516mzzxwgxhp4pq";
      name = "wallpaper-rose-pine-1-funky-shapes.webp";
    };
  };
  "solitude" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/solitude/backgrounds/1-on-pole.webp";
      sha256 = "0wgfir2qnivv1xgp43i0hmmm87iwsqckz2i59y92d24mxp78bih9";
      name = "wallpaper-solitude-1-on-pole.webp";
    };
  };
  "tokyo-night" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/tokyo-night/backgrounds/0-winding-road.webp";
      sha256 = "0azdkjvzsbnl7hbmjbfphfjhq5lbrz170cdwww93hf6fr3hw6jdi";
      name = "wallpaper-tokyo-night-0-winding-road.webp";
    };
  };
  "vantablack" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/vantablack/backgrounds/0-dot-hands.webp";
      sha256 = "186k7a01xfkkywzmm63gkqx76706ljnk5ivdw7gls1bd832hs7m5";
      name = "wallpaper-vantablack-0-dot-hands.webp";
    };
  };
  "white" = {
    ext = "webp";
    file = fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/white/backgrounds/1-white.webp";
      sha256 = "1wl0xpldykg7spg0a0d630isbi620i222zhk3yapia9vmpvl4brg";
      name = "wallpaper-white-1-white.webp";
    };
  };
}
