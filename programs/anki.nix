{
  config,
  pkgs,
  userName,
  ...
}:
let
  pythonWithSpacy = pkgs.python313.withPackages (ps: [ ps.spacy ]);
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
