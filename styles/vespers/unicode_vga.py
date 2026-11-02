import sys
from itertools import groupby
from pathlib import Path

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen


def read_glyph(block):
    lines = block.splitlines()
    properties = {line.split()[0]: line.split()[1:] for line in lines if line.strip()}
    codepoint = int(properties["ENCODING"][0])
    width, height, x_offset, y_offset = map(int, properties["BBX"])
    rows = lines[lines.index("BITMAP") + 1:lines.index("ENDCHAR")]
    pen = TTGlyphPen(None)
    for row_index, row in enumerate(rows):
        bits = f"{int(row, 16):0{len(row) * 4}b}"[:width]
        for filled, cells in groupby(enumerate(bits), lambda cell: cell[1]):
            run = list(cells)
            if filled == "1":
                left = (x_offset + run[0][0]) * 64
                right = (x_offset + run[-1][0] + 1) * 64
                bottom = (y_offset + height - row_index - 1) * 64
                pen.moveTo((left, bottom))
                pen.lineTo((left, bottom + 64))
                pen.lineTo((right, bottom + 64))
                pen.lineTo((right, bottom))
                pen.closePath()
    return codepoint, int(properties["DWIDTH"][0]) * 64, pen.glyph()


def build_font(source, destination):
    glyphs = [read_glyph(block) for block in Path(source).read_text().split("STARTCHAR ")[1:]]
    mapped = {codepoint: (f"uni{codepoint:04X}", advance, glyph) for codepoint, advance, glyph in glyphs if codepoint >= 0}
    assert 0x017F in mapped
    assert all(codepoint in mapped for codepoint in range(0x2500, 0x2580))
    font = FontBuilder(1024, isTTF=True)
    font.setupGlyphOrder([".notdef"] + [item[0] for item in mapped.values()])
    font.setupCharacterMap({codepoint: item[0] for codepoint, item in mapped.items()})
    font.setupGlyf({".notdef": mapped[0][2], **{name: glyph for name, _, glyph in mapped.values()}})
    font.setupHorizontalMetrics({
        ".notdef": (512, getattr(mapped[0][2], "xMin", 0)),
        **{name: (advance, getattr(glyph, "xMin", 0)) for name, advance, glyph in mapped.values()},
    })
    font.setupHorizontalHeader(ascent=768, descent=-256)
    font.setupNameTable({
        "familyName": "Unicode VGA", "styleName": "Regular",
        "uniqueFontIdentifier": "Unicode VGA pixel outlines 1.0",
        "fullName": "Unicode VGA Regular", "psName": "UnicodeVGA-Regular",
        "version": "Version 1.0",
        "copyright": "Copyright (c) 2000 Dmitry Bolkhovityanov",
        "licenseDescription": "Freely distributable and modifiable under the X license; derived from UNI-VGA.",
    })
    font.setupOS2(sTypoAscender=768, sTypoDescender=-256, sTypoLineGap=0, usWinAscent=768, usWinDescent=256)
    font.setupPost(isFixedPitch=1)
    font.setupMaxp()
    font.font["head"].created = font.font["head"].modified = 2082844800
    font.save(destination)


build_font(*sys.argv[1:])
