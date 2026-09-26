# GERADO -- nao edite a mao.
#
# Todos os backgrounds de cada tema do Omarchy (github.com/omacom/omarchy,
# branch quattro, themes/<nome>/backgrounds/). 92 arquivos, ~52 MB: baixados
# e verificados pelo Nix, nao versionados.
#
# A lista e ordenada pelo nome do arquivo, que e como o Omarchy numera os
# backgrounds -- o primeiro e o default do tema.
#
# `dracula` nao aparece aqui: usa configs/hypr/nixos.png, que e escolha do
# usuario. Ver home/themes.nix.
{ fetchurl }:
{
  "catppuccin-latte" = [
    {
      name = "1-color-fade.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/catppuccin-latte/backgrounds/1-color-fade.webp";
        sha256 = "00v6sfzy0bpqabynb1y94j8ic0zvdkxynvpg63k88fbif0bj3jy4";
        name = "bg-catppuccin-latte-1-color-fade.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/catppuccin-latte/backgrounds/omarchy.webp";
        sha256 = "0cid4j8filanswzgrhvvbmbkx3gyiqxka3z9jm10hf2ifn4y30l4";
        name = "bg-catppuccin-latte-omarchy.webp";
      };
    }
  ];
  "catppuccin" = [
    {
      name = "1-totoro.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/catppuccin/backgrounds/1-totoro.webp";
        sha256 = "1di4yybbw8cm0fs4s1jn93xak4cm2sw8vppfa9z6n0fk1ridm5j8";
        name = "bg-catppuccin-1-totoro.webp";
      };
    }
    {
      name = "2-waves.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/catppuccin/backgrounds/2-waves.webp";
        sha256 = "1kj1c2s61n68qg996hky1znhhjgyp20n7abkpkaz3nqlk3plgqsz";
        name = "bg-catppuccin-2-waves.webp";
      };
    }
    {
      name = "3-blue-eye.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/catppuccin/backgrounds/3-blue-eye.webp";
        sha256 = "0jlm55hncyc4517gd5aiawjh37i3hw7hcy3ry5r3n9bm8lj3qx3h";
        name = "bg-catppuccin-3-blue-eye.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/catppuccin/backgrounds/omarchy.webp";
        sha256 = "0aa3b570vd13y6gyndm68dric1indm97cf89vpxdw7hrw88r5jr4";
        name = "bg-catppuccin-omarchy.webp";
      };
    }
  ];
  "ethereal" = [
    {
      name = "1-cosmic.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/ethereal/backgrounds/1-cosmic.webp";
        sha256 = "0qxbvmx5hqclqj1lvbff0rxcwrab3r04dxxxwidc4p5ssh3ia973";
        name = "bg-ethereal-1-cosmic.webp";
      };
    }
    {
      name = "2-meadow.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/ethereal/backgrounds/2-meadow.webp";
        sha256 = "0vaz77ckafxq9ygb8lmc1qjkk9ysw1hw12iq713hjxnq72vyxcb0";
        name = "bg-ethereal-2-meadow.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/ethereal/backgrounds/omarchy.webp";
        sha256 = "0y8pdag33yzgi4jcw4a53gn1p72dpf3llvcllqnssfjpzmyj66v5";
        name = "bg-ethereal-omarchy.webp";
      };
    }
  ];
  "everforest" = [
    {
      name = "1-tree-tops.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/everforest/backgrounds/1-tree-tops.webp";
        sha256 = "0y125fzp2v6245rivaw2nx5xk86c91nnjzxl918ycxmrrwmpaq13";
        name = "bg-everforest-1-tree-tops.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/everforest/backgrounds/omarchy.webp";
        sha256 = "06b4gia2gw9bbfvkwd6kzan2wp2zxpkr6fnpjl2xj08lj6i4nzss";
        name = "bg-everforest-omarchy.webp";
      };
    }
  ];
  "flexoki-light" = [
    {
      name = "1-orb.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/flexoki-light/backgrounds/1-orb.webp";
        sha256 = "03z97raxcdq5l5wnr1iq6s0ykf22asz980xvbjhz35bs5vzw3y1p";
        name = "bg-flexoki-light-1-orb.webp";
      };
    }
    {
      name = "2-omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/flexoki-light/backgrounds/2-omarchy.webp";
        sha256 = "1fzh0hdsi9mqdsxrgrcayyyp5dga9nqhdnnp9nlvhyslqrbx98x3";
        name = "bg-flexoki-light-2-omarchy.webp";
      };
    }
  ];
  "gruvbox" = [
    {
      name = "1-the-backwater.jpg";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/gruvbox/backgrounds/1-the-backwater.jpg";
        sha256 = "1imaxha4vf98n5njlwg9pw7vpzm0aqdzh3w2ib089y8a6ypcdkqk";
        name = "bg-gruvbox-1-the-backwater.jpg";
      };
    }
    {
      name = "2-flower-basket.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/gruvbox/backgrounds/2-flower-basket.webp";
        sha256 = "0xyvk0dgicnqm8kwv1qfzjqldia126c3limrfzrwnsvp2ggx3j36";
        name = "bg-gruvbox-2-flower-basket.webp";
      };
    }
    {
      name = "3-village-square.jpg";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/gruvbox/backgrounds/3-village-square.jpg";
        sha256 = "1p0w8pk9nf2z3k8xjxxrsacnxn1xh6brzkz972l7cs7hpqnxbi4s";
        name = "bg-gruvbox-3-village-square.jpg";
      };
    }
    {
      name = "4-idyllic-procession.jpg";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/gruvbox/backgrounds/4-idyllic-procession.jpg";
        sha256 = "1iam1bk3vixgac807frim9cni030da14fddidx0nksx5ccrff2my";
        name = "bg-gruvbox-4-idyllic-procession.jpg";
      };
    }
    {
      name = "5-leaves.jpg";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/gruvbox/backgrounds/5-leaves.jpg";
        sha256 = "0vgnjirv51b9iz5sz8xhg1l7hcc5388gb2l1fiz8wb2angbkrgfd";
        name = "bg-gruvbox-5-leaves.jpg";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/gruvbox/backgrounds/omarchy.webp";
        sha256 = "1s87ghkwlz1y0q35ka318zy1xafq38z4rfbkpc1y3wyi1ymrp188";
        name = "bg-gruvbox-omarchy.webp";
      };
    }
  ];
  "hackerman" = [
    {
      name = "1-synth-scape.jpg";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/hackerman/backgrounds/1-synth-scape.jpg";
        sha256 = "0zipgbr9g17hm697mrfq7wfirsl94fhygps33ggy017j6m4mkln7";
        name = "bg-hackerman-1-synth-scape.jpg";
      };
    }
    {
      name = "2-geometric.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/hackerman/backgrounds/2-geometric.webp";
        sha256 = "0kahdy0k15gw0a1gvk4ml6g2dhw3azk1y8270my48j3wzv8ycc5k";
        name = "bg-hackerman-2-geometric.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/hackerman/backgrounds/omarchy.webp";
        sha256 = "0ylwff64pcq2blh30iq3gd6z2q34agmjxz9cm9w4agklrmbcvm9x";
        name = "bg-hackerman-omarchy.webp";
      };
    }
  ];
  "kanagawa" = [
    {
      name = "1-kanagawa.jpg";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/kanagawa/backgrounds/1-kanagawa.jpg";
        sha256 = "0zdji2gmrh7glh18m4flnp5w6f98k5hvc0vnp06rylw8frqpv0cv";
        name = "bg-kanagawa-1-kanagawa.jpg";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/kanagawa/backgrounds/omarchy.webp";
        sha256 = "1ign7yyf8p9r4xg4aksqf2hwrr1f3jc6s785qa00wzrkfsbyfzz2";
        name = "bg-kanagawa-omarchy.webp";
      };
    }
  ];
  "last-horizon" = [
    {
      name = "1-eyes-wide.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/last-horizon/backgrounds/1-eyes-wide.webp";
        sha256 = "1m3va8z4m8fx08g1miajbb6zs7c4769wrcyjfxfl6xdx4pm2xk2k";
        name = "bg-last-horizon-1-eyes-wide.webp";
      };
    }
    {
      name = "2-blink.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/last-horizon/backgrounds/2-blink.webp";
        sha256 = "0mbik7cmrmzrv3caasp38wz2hvdl9c348ycqg54paf9phjmh7v7a";
        name = "bg-last-horizon-2-blink.webp";
      };
    }
    {
      name = "3-bokeh.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/last-horizon/backgrounds/3-bokeh.webp";
        sha256 = "0c0wg0i69y9i714nk4axpxmnap9xd1g1c6plrin3s5xvlqyja6zr";
        name = "bg-last-horizon-3-bokeh.webp";
      };
    }
    {
      name = "4-new-horizons.jpg";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/last-horizon/backgrounds/4-new-horizons.jpg";
        sha256 = "0pzb5zqi8jf8n4xn3l3nzg2zx3vbymj2cq8kq74xf5rn5s2fq4vb";
        name = "bg-last-horizon-4-new-horizons.jpg";
      };
    }
  ];
  "lumon" = [
    {
      name = "01-united-in-severance.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/lumon/backgrounds/01-united-in-severance.webp";
        sha256 = "19bka2mphq049hclfn8c45563qy4nqi8ib3k59gysxr0n963vyyd";
        name = "bg-lumon-01-united-in-severance.webp";
      };
    }
    {
      name = "02-opinions-equally.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/lumon/backgrounds/02-opinions-equally.webp";
        sha256 = "1if7gl9f2372a4m8migkffk5l6c25swi0ng06zxl75k5bylhzwpc";
        name = "bg-lumon-02-opinions-equally.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/lumon/backgrounds/omarchy.webp";
        sha256 = "0dm0p3lsv5l75bid9dnwkmv5gqga22v13xm14vag7nzwa2fwp095";
        name = "bg-lumon-omarchy.webp";
      };
    }
  ];
  "lupine" = [
    {
      name = "01-cherry-blossom-bokeh.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/lupine/backgrounds/01-cherry-blossom-bokeh.webp";
        sha256 = "0si9r7kxdqzna0f2y7hbr24zd8cck04ymg0ynfmbbyl54szlmbcr";
        name = "bg-lupine-01-cherry-blossom-bokeh.webp";
      };
    }
    {
      name = "02-cherry-blossom-white.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/lupine/backgrounds/02-cherry-blossom-white.webp";
        sha256 = "092fl02nwxhz1r55w3l0znqzn8qaf1y2rhdyizngrmd16jnz6p0p";
        name = "bg-lupine-02-cherry-blossom-white.webp";
      };
    }
    {
      name = "03-pastel-clouds.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/lupine/backgrounds/03-pastel-clouds.webp";
        sha256 = "13v9x368yfvxnpfibsxirckxnhyx0qp19j0bz5bh9rl1mxrb2jqk";
        name = "bg-lupine-03-pastel-clouds.webp";
      };
    }
    {
      name = "04-elegant-blue-wave.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/lupine/backgrounds/04-elegant-blue-wave.webp";
        sha256 = "0v1m4fa8nxqi1mw458zdkj6s14dcihmi1vc037iwymnl5l6rrc0g";
        name = "bg-lupine-04-elegant-blue-wave.webp";
      };
    }
    {
      name = "05-abstract-wave.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/lupine/backgrounds/05-abstract-wave.webp";
        sha256 = "0zynclplx56xabri120wj3kgyyr5vsfgbdwi3i2sjlrskn11xvgp";
        name = "bg-lupine-05-abstract-wave.webp";
      };
    }
    {
      name = "06-omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/lupine/backgrounds/06-omarchy.webp";
        sha256 = "06mj68g75wykplk3n94m7lh7lr1zlvkl0jf5vdp6r2z2n0pcm6q6";
        name = "bg-lupine-06-omarchy.webp";
      };
    }
  ];
  "matte-black" = [
    {
      name = "0-ship-at-sea.jpg";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/matte-black/backgrounds/0-ship-at-sea.jpg";
        sha256 = "1b1rw0pwx2lv97d9k5w70j7r6yg6in6s49mq0a8qmyykvwd6kyjm";
        name = "bg-matte-black-0-ship-at-sea.jpg";
      };
    }
    {
      name = "1-dark-waters.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/matte-black/backgrounds/1-dark-waters.webp";
        sha256 = "06s8s29dqs33a5bpiaw922ln39ip51w4rsx6b5n9gppdkv1zczii";
        name = "bg-matte-black-1-dark-waters.webp";
      };
    }
    {
      name = "2-dot-hands.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/matte-black/backgrounds/2-dot-hands.webp";
        sha256 = "186k7a01xfkkywzmm63gkqx76706ljnk5ivdw7gls1bd832hs7m5";
        name = "bg-matte-black-2-dot-hands.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/matte-black/backgrounds/omarchy.webp";
        sha256 = "1v4cv49sp10iaia1lj0nkf9na0zqm140l5r27vs77c19visvlrxq";
        name = "bg-matte-black-omarchy.webp";
      };
    }
  ];
  "miasma" = [
    {
      name = "01-nature-of-fear.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/miasma/backgrounds/01-nature-of-fear.webp";
        sha256 = "1920ap007kgdi79dgcf17ylgrw25mdhl93bkzwz9xsly7a3g5icb";
        name = "bg-miasma-01-nature-of-fear.webp";
      };
    }
    {
      name = "02-crowned.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/miasma/backgrounds/02-crowned.webp";
        sha256 = "0za1yrsqhysz5s64fhw5c6yrbml84gfi9z4v2y65zmkfz401x1xj";
        name = "bg-miasma-02-crowned.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/miasma/backgrounds/omarchy.webp";
        sha256 = "0nlxqvd39dpzb3gl6ggil2r4a7plxmmml273s332wdcpx6adi0ah";
        name = "bg-miasma-omarchy.webp";
      };
    }
  ];
  "nord" = [
    {
      name = "0-black-moon.jpg";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/nord/backgrounds/0-black-moon.jpg";
        sha256 = "10gziqsr1bks55f6xxgcccg26vgb0kcdhk890jba7ffbskvznwv8";
        name = "bg-nord-0-black-moon.jpg";
      };
    }
    {
      name = "1-city-view.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/nord/backgrounds/1-city-view.webp";
        sha256 = "1518irp9x4rsksy5sy12p3r2vx769qdrim626ar5mdyl5l4bjjdn";
        name = "bg-nord-1-city-view.webp";
      };
    }
    {
      name = "2-night-hawks.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/nord/backgrounds/2-night-hawks.webp";
        sha256 = "12a0h9s5ggqvcqaimsizpijigwzlh1r7jylwsjpm07qv5amjdzs3";
        name = "bg-nord-2-night-hawks.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/nord/backgrounds/omarchy.webp";
        sha256 = "0q7y1wp2rhj8ia9blvpl812rjj4c4hp58pn2gwyz6xdr9rln0wc7";
        name = "bg-nord-omarchy.webp";
      };
    }
  ];
  "osaka-jade" = [
    {
      name = "1-glowing-city.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/osaka-jade/backgrounds/1-glowing-city.webp";
        sha256 = "0ijrib7c8k1cfw10w4248gzmq2pdyyb67ipwql3s6pf6r2kw8d6j";
        name = "bg-osaka-jade-1-glowing-city.webp";
      };
    }
    {
      name = "2-shaded-entrance.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/osaka-jade/backgrounds/2-shaded-entrance.webp";
        sha256 = "1yv7akb872lr7i55nqgxdkh7d8f7wssrsykbicwdykaiilg4pjha";
        name = "bg-osaka-jade-2-shaded-entrance.webp";
      };
    }
    {
      name = "3-mountain-moon.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/osaka-jade/backgrounds/3-mountain-moon.webp";
        sha256 = "1grgwkxnhj2f5c9wxiyqq1gjavgnz7p5d5prd1xn4s8hffza2bwx";
        name = "bg-osaka-jade-3-mountain-moon.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/osaka-jade/backgrounds/omarchy.webp";
        sha256 = "0kls0xzvqgf87d556jwl58p8d78p7mg2x8g6k2nyf3g7iw6k1lf3";
        name = "bg-osaka-jade-omarchy.webp";
      };
    }
  ];
  "retro-82" = [
    {
      name = "1-in-the-groove.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/retro-82/backgrounds/1-in-the-groove.webp";
        sha256 = "12ldfxa11lcdpmb8nknn16ymf646q6zipfn3dw6kf460f3gyznf9";
        name = "bg-retro-82-1-in-the-groove.webp";
      };
    }
    {
      name = "2-dusk-guardian.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/retro-82/backgrounds/2-dusk-guardian.webp";
        sha256 = "17laf2d9bxnflk9vg189zkijgxfsa3aqrlm6ppjw7vhw38f1043s";
        name = "bg-retro-82-2-dusk-guardian.webp";
      };
    }
    {
      name = "3-glassy-lines.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/retro-82/backgrounds/3-glassy-lines.webp";
        sha256 = "06yzc4qnrb40svd7m8msy7h59nirdk50r8i4jfn2rybr7jxrcpg9";
        name = "bg-retro-82-3-glassy-lines.webp";
      };
    }
    {
      name = "4-gateway.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/retro-82/backgrounds/4-gateway.webp";
        sha256 = "0n94mcrj5bzlwd7vrm8yarblv9gpf3lhmqy38fhhlr352jkp9zjh";
        name = "bg-retro-82-4-gateway.webp";
      };
    }
    {
      name = "5-zen-boat.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/retro-82/backgrounds/5-zen-boat.webp";
        sha256 = "0sk0sk83i76nz2lzdr4p48fiwrkmml75qk5c991l53jrbza0hr01";
        name = "bg-retro-82-5-zen-boat.webp";
      };
    }
    {
      name = "6-abstract-pyramids.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/retro-82/backgrounds/6-abstract-pyramids.webp";
        sha256 = "1rpcshyac35ccrmf50nyz4ysczqb67x7944fqhil8a9w1p0glmag";
        name = "bg-retro-82-6-abstract-pyramids.webp";
      };
    }
    {
      name = "7-the-journey.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/retro-82/backgrounds/7-the-journey.webp";
        sha256 = "0765zgknrzz3pg2dahyl45s14jfczmp700pwy45ayxwfwc3l7611";
        name = "bg-retro-82-7-the-journey.webp";
      };
    }
    {
      name = "8-glitter-glass.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/retro-82/backgrounds/8-glitter-glass.webp";
        sha256 = "1vcwq59fn2h2gzpf53bzzvc5bjm8023g6ns0db27r9kgalndqw4a";
        name = "bg-retro-82-8-glitter-glass.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/retro-82/backgrounds/omarchy.webp";
        sha256 = "0wp8qi2xad3807nh5zkpbk7p03mzn2fl8zyy2pmckyn573dx5yq8";
        name = "bg-retro-82-omarchy.webp";
      };
    }
  ];
  "ristretto" = [
    {
      name = "0-launch.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/ristretto/backgrounds/0-launch.webp";
        sha256 = "0i2hk2ms0vidbbnhlsbrww136vicragjq5f0x1hn7wybwnzsgls2";
        name = "bg-ristretto-0-launch.webp";
      };
    }
    {
      name = "1-color-curves.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/ristretto/backgrounds/1-color-curves.webp";
        sha256 = "0m0pz3vqrwl25qryh9w9sgdiq4avmpykkbbrb4piz41nvi1i0b4z";
        name = "bg-ristretto-1-color-curves.webp";
      };
    }
    {
      name = "2-coffee-beans.jpg";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/ristretto/backgrounds/2-coffee-beans.jpg";
        sha256 = "1kf01hdbmlx6ljr40yjiyasiliy6anzcgx36f1ygq2a00j37vmm2";
        name = "bg-ristretto-2-coffee-beans.jpg";
      };
    }
    {
      name = "3-industrial-moon.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/ristretto/backgrounds/3-industrial-moon.webp";
        sha256 = "0b8ca4fpw8mbvj5v4pn541hi9nmn0ibzq0wfhvzrmhycciamrfl3";
        name = "bg-ristretto-3-industrial-moon.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/ristretto/backgrounds/omarchy.webp";
        sha256 = "10k5k4g8nh1v7ix2vmzspp9xhhb3g4bpv7mjpwxwfm86zizr1nyj";
        name = "bg-ristretto-omarchy.webp";
      };
    }
  ];
  "rose-pine" = [
    {
      name = "1-funky-shapes.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/rose-pine/backgrounds/1-funky-shapes.webp";
        sha256 = "109bkwrq9r64zf7r8qhqn3a91mdplixfh869m516mzzxwgxhp4pq";
        name = "bg-rose-pine-1-funky-shapes.webp";
      };
    }
    {
      name = "2-dot-map.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/rose-pine/backgrounds/2-dot-map.webp";
        sha256 = "1awhhsyr6rpqdxaic3nbcwl9s36vhaf4yklijf0zvkmg98x0jlq3";
        name = "bg-rose-pine-2-dot-map.webp";
      };
    }
    {
      name = "3-omarchy-plants.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/rose-pine/backgrounds/3-omarchy-plants.webp";
        sha256 = "18fwcm6gxqlmim548h8ghach87x28c3zwd83imna45k0ai749x8w";
        name = "bg-rose-pine-3-omarchy-plants.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/rose-pine/backgrounds/omarchy.webp";
        sha256 = "0npzgja8y7d3zcd6404zbw9d38g9wz6iqfss24g3r9cfcfcjp0hn";
        name = "bg-rose-pine-omarchy.webp";
      };
    }
  ];
  "solitude" = [
    {
      name = "1-on-pole.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/solitude/backgrounds/1-on-pole.webp";
        sha256 = "0wgfir2qnivv1xgp43i0hmmm87iwsqckz2i59y92d24mxp78bih9";
        name = "bg-solitude-1-on-pole.webp";
      };
    }
    {
      name = "2-wreakage.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/solitude/backgrounds/2-wreakage.webp";
        sha256 = "1b1w0442jq136q11ygy4y8y0j0hsszww6k35r2pb6cgpvvg0ngx7";
        name = "bg-solitude-2-wreakage.webp";
      };
    }
    {
      name = "3-climb.jpg";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/solitude/backgrounds/3-climb.jpg";
        sha256 = "1dv6v9601ylzcnjrn7i5cbw72ak785rfbjgkiylb1dl7gyx32yma";
        name = "bg-solitude-3-climb.jpg";
      };
    }
    {
      name = "4-ether.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/solitude/backgrounds/4-ether.webp";
        sha256 = "15rynlnjr1gkr2bxa9cmc48m2dkvbwrz2dqw2pnfrf0prc5y3x52";
        name = "bg-solitude-4-ether.webp";
      };
    }
    {
      name = "5-eyed.jpg";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/solitude/backgrounds/5-eyed.jpg";
        sha256 = "1ii2dydizahspkr0dv8mq5m14l9p75lr91wnx8kl93zm6c1fv27b";
        name = "bg-solitude-5-eyed.jpg";
      };
    }
  ];
  "tokyo-night" = [
    {
      name = "0-winding-road.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/tokyo-night/backgrounds/0-winding-road.webp";
        sha256 = "0azdkjvzsbnl7hbmjbfphfjhq5lbrz170cdwww93hf6fr3hw6jdi";
        name = "bg-tokyo-night-0-winding-road.webp";
      };
    }
    {
      name = "1-quattro.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/tokyo-night/backgrounds/1-quattro.webp";
        sha256 = "0iki8krwb7xv3baxm2csw1jxyzl6ychvdpd8hqwi2n17dl86rff9";
        name = "bg-tokyo-night-1-quattro.webp";
      };
    }
    {
      name = "2-swirl-buck.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/tokyo-night/backgrounds/2-swirl-buck.webp";
        sha256 = "0nhhhk9ch68k23z35js5w1skmh4nvywbipqmz8vb7186ww6als6h";
        name = "bg-tokyo-night-2-swirl-buck.webp";
      };
    }
    {
      name = "3-sunset-lake.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/tokyo-night/backgrounds/3-sunset-lake.webp";
        sha256 = "0jccbygrhn5g0g9s925dbh6xism2l58qyibhg6b6nfg2spj9bg7a";
        name = "bg-tokyo-night-3-sunset-lake.webp";
      };
    }
    {
      name = "4-omakub.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/tokyo-night/backgrounds/4-omakub.webp";
        sha256 = "19qaz1w08kwz196v729pjr10dbl6nv5m65az374q864vw582xq0x";
        name = "bg-tokyo-night-4-omakub.webp";
      };
    }
    {
      name = "5-oma-cityscape.jpg";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/tokyo-night/backgrounds/5-oma-cityscape.jpg";
        sha256 = "0p2ff5gvr5v3n5f6dxc1nihykfmla0s77his1mpzlcrbf8wxdq92";
        name = "bg-tokyo-night-5-oma-cityscape.jpg";
      };
    }
    {
      name = "6-oma.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/tokyo-night/backgrounds/6-oma.webp";
        sha256 = "016hn64zxzjx4pz3prvkrx1azslixnw21p893ww16drc89aibbhx";
        name = "bg-tokyo-night-6-oma.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/tokyo-night/backgrounds/omarchy.webp";
        sha256 = "0rjmlhv4n7isdnqyhwsjwfahkla5zl7k1rg4jxpdb8b3fx66v77g";
        name = "bg-tokyo-night-omarchy.webp";
      };
    }
  ];
  "vantablack" = [
    {
      name = "0-dot-hands.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/vantablack/backgrounds/0-dot-hands.webp";
        sha256 = "186k7a01xfkkywzmm63gkqx76706ljnk5ivdw7gls1bd832hs7m5";
        name = "bg-vantablack-0-dot-hands.webp";
      };
    }
    {
      name = "1-twisted-stairs.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/vantablack/backgrounds/1-twisted-stairs.webp";
        sha256 = "01hysqcfzd431hx3blvdvg1rf7y136fhlxp14cqlnd4bicm49q85";
        name = "bg-vantablack-1-twisted-stairs.webp";
      };
    }
    {
      name = "2-layers-deep.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/vantablack/backgrounds/2-layers-deep.webp";
        sha256 = "1k9i1ckzfqjl4468i80y5jf7zkg9hqpbxs57hk7bnrs9xg2215q5";
        name = "bg-vantablack-2-layers-deep.webp";
      };
    }
    {
      name = "3-layers-stacked.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/vantablack/backgrounds/3-layers-stacked.webp";
        sha256 = "1lxs6ws2k2vzd2k24ymwxgzwrq4jkd6ih84qjf529i5q9w6cw03c";
        name = "bg-vantablack-3-layers-stacked.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/vantablack/backgrounds/omarchy.webp";
        sha256 = "0gdhsbj1q380d8bdjw57mjfwki7sgfw947rzpr9v56zz4glcwxbm";
        name = "bg-vantablack-omarchy.webp";
      };
    }
  ];
  "white" = [
    {
      name = "1-white.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/white/backgrounds/1-white.webp";
        sha256 = "1wl0xpldykg7spg0a0d630isbi620i222zhk3yapia9vmpvl4brg";
        name = "bg-white-1-white.webp";
      };
    }
    {
      name = "2-white.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/white/backgrounds/2-white.webp";
        sha256 = "13s9zq4nx1v7h14qgfv5zf38ypxkm7c71w6i3yxcmll24xyfs6p8";
        name = "bg-white-2-white.webp";
      };
    }
    {
      name = "3-white.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/white/backgrounds/3-white.webp";
        sha256 = "0j5bw8km7zw6y8xkls0d0b78djmv17prpq1q16l84v7cbna6iy9k";
        name = "bg-white-3-white.webp";
      };
    }
    {
      name = "omarchy.webp";
      file = fetchurl {
        url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/white/backgrounds/omarchy.webp";
        sha256 = "1mzsz3jwwlw8j72d43zvsp5s5dkwfp9fc39yi98x3xqbbscgynag";
        name = "bg-white-omarchy.webp";
      };
    }
  ];
}
