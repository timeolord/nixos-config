{ lib, pkgs }:
pkgs.runCommand "unicode-vga-scalable" {
  nativeBuildInputs = [ (pkgs.python3.withPackages (ps: [ ps.fonttools ps.skia-pathops ])) ];
  meta = { description = "Unicode VGA with scalable pixel outlines"; license = lib.licenses.mit; };
} ''
  mkdir -p "$out/share/fonts/truetype"
  python ${./unicode_vga.py} ${pkgs.uni-vga.bdf}/share/fonts/u_vga16.bdf "$out/share/fonts/truetype/unicode-vga.ttf"
''
