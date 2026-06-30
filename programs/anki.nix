{
  config,
  pkgs,
  userName,
  ...
}:
let
  fr-core-news-lg = pkgs.python313.pkgs.buildPythonPackage {
    pname = "fr_core_news_lg";
    version = "3.8.0";
    format = "wheel";
    src = pkgs.fetchurl {
      url = "https://github.com/explosion/spacy-models/releases/download/fr_core_news_lg-3.8.0/fr_core_news_lg-3.8.0-py3-none-any.whl";
      hash = "sha256-2lv3/IYK9kKT2IY4tEFrPeOikAW3hb//Z9CbBsdzRd4=";
    };
    dependencies = [ pkgs.python313.pkgs.spacy ];
    doCheck = false;
  };
  pythonWithSpacy = pkgs.python313.withPackages (ps: [ ps.spacy fr-core-news-lg ]);
  ankiWithSpacy = pkgs.symlinkJoin {
    name = "anki-with-spacy";
    paths = [ pkgs.anki ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/anki \
        --prefix PYTHONPATH : "${pythonWithSpacy}/${pkgs.python313.sitePackages}"
    '';
  };
in
{
  home.packages = [ ankiWithSpacy ];
}
