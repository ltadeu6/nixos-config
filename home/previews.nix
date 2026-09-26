# GERADO -- nao edite a mao.
#
# Miniatura por tema, do `themes/<nome>/preview.png` do Omarchy
# (github.com/omacom/omarchy, branch quattro). Mostra a UI do tema, nao so o
# wallpaper, que e o que torna o seletor visual util para escolher.
#
# Baixado e verificado pelo Nix, nao versionado (~8 MB). `dracula` nao tem
# preview upstream e cai no proprio wallpaper (ver home/themes.nix).
{ fetchurl }:
{
  "catppuccin-latte" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/catppuccin-latte/preview.png";
    sha256 = "0q4klry0vnid8s03x82908ljs4jvaljg7wgyrl3l88bhnc37bgc2";
    name = "preview-catppuccin-latte.png";
  };
  "catppuccin" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/catppuccin/preview.png";
    sha256 = "14jp4zjnwcbpbicp06yd5pi3p2byk6wzsnkqmj1yyh0gj268ks8f";
    name = "preview-catppuccin.png";
  };
  "ethereal" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/ethereal/preview.png";
    sha256 = "0i4xyjc5h30c19n4jfh3ckvgv3a3kkv5py0a9qf225gvr3dnki06";
    name = "preview-ethereal.png";
  };
  "everforest" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/everforest/preview.png";
    sha256 = "09mpzzzqx7wzq2qafy6dkkpdc4wfc0wyjq06ic2pvvg8pcrg6586";
    name = "preview-everforest.png";
  };
  "flexoki-light" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/flexoki-light/preview.png";
    sha256 = "15mpfwk0q84s1dff3rp13syym1a4c8v28c1k6gvmiw7ax2pajrsh";
    name = "preview-flexoki-light.png";
  };
  "gruvbox" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/gruvbox/preview.png";
    sha256 = "1b0q71scpzvxzj18hz19c1c5kh1y4p7p8lgv19n48lkjmb9wh48y";
    name = "preview-gruvbox.png";
  };
  "hackerman" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/hackerman/preview.png";
    sha256 = "1v84gkh3yym09qni5ql3ls4q20an8fqjwih4rjkjc124lg0k0i57";
    name = "preview-hackerman.png";
  };
  "kanagawa" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/kanagawa/preview.png";
    sha256 = "0ph3fyjpw6nlvaqsnizqhi63x4jrdkm01g7jqqycvrc21n07nisq";
    name = "preview-kanagawa.png";
  };
  "last-horizon" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/last-horizon/preview.png";
    sha256 = "17khvkxxgbq8lh9mqxiqbs2w788y91jwnmdk0asdxybqacs9mz8j";
    name = "preview-last-horizon.png";
  };
  "lumon" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/lumon/preview.png";
    sha256 = "0ff43198iv22rjj6hqp4f8jk96v30mz3fan2n2syq6ix8hhqi1k6";
    name = "preview-lumon.png";
  };
  "lupine" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/lupine/preview.png";
    sha256 = "1arldgimx56wlzf3hxz784kwxksrr9h5h63m0zaghg62q9spjbrp";
    name = "preview-lupine.png";
  };
  "matte-black" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/matte-black/preview.png";
    sha256 = "065fwm56nxxyzrgzx8x5w536n6007nfki3nchl4725r67xwp1gq2";
    name = "preview-matte-black.png";
  };
  "miasma" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/miasma/preview.png";
    sha256 = "18ry13zwh00al7nf872xsmv9ikdj8z0jbs9dxjic4hq8pwas1xwj";
    name = "preview-miasma.png";
  };
  "nord" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/nord/preview.png";
    sha256 = "1iripf0j8qzdgdcdwb1sbq25dcm8j60gnx0pkgqp409pca3pr708";
    name = "preview-nord.png";
  };
  "osaka-jade" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/osaka-jade/preview.png";
    sha256 = "1j4risyk0dyji2jxw6bjgjcgk1hi8cdzqkmxlxb4sqhaay697gk3";
    name = "preview-osaka-jade.png";
  };
  "retro-82" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/retro-82/preview.png";
    sha256 = "0x8xl32rbjlldvsxbgsrvfs10mbikq7163v9y4l26v5hf960m4ck";
    name = "preview-retro-82.png";
  };
  "ristretto" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/ristretto/preview.png";
    sha256 = "0n54gavidgci2b32pg7sk06zvwqdqrsq1z8yx5zw6fy76m6bx3gn";
    name = "preview-ristretto.png";
  };
  "rose-pine" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/rose-pine/preview.png";
    sha256 = "18br6xsxcwgjy8n6j2g83m0z4sgprf2vl35wgdw3715kgqy1r698";
    name = "preview-rose-pine.png";
  };
  "solitude" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/solitude/preview.png";
    sha256 = "1niz2q7fddvwyizzfw4b9wl8fj3w8nlfmkchqbcrjf6hvyx29j5l";
    name = "preview-solitude.png";
  };
  "tokyo-night" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/tokyo-night/preview.png";
    sha256 = "1yyqh974jk7x4n4d72mff4kffnixfjyh6bqdbccivbs8v6i8fahy";
    name = "preview-tokyo-night.png";
  };
  "vantablack" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/vantablack/preview.png";
    sha256 = "1zc88fnl82a5wl1vb4nagc8ksa95a5743wmrgzlb5zkvchwb3fbp";
    name = "preview-vantablack.png";
  };
  "white" = fetchurl {
    url = "https://raw.githubusercontent.com/omacom/omarchy/quattro/themes/white/preview.png";
    sha256 = "1v5mwxkfnb0zv6hni58k36faldn8xj8mmaabnyfnydli01qzdybc";
    name = "preview-white.png";
  };
}
