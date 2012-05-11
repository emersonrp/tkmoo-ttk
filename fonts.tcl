set fonts_plain      {helvetica 10}
set fonts_fixedwidth {courier 10}
set fonts_bold       {helvetica 10 bold}
set fonts_italic     {helvetica 10 italic}
set fonts_header     {helvetica 12 bold italic}

proc fonts.get font {
    return [fonts.$font]
}

proc fonts.fixedwidth {} {
    global fonts_fixedwidth
    return [worlds.get_generic $fonts_fixedwidth fontFixedwidth FontFixedwidth FontFixedwidth]
}

proc fonts.plain {} {
    global fonts_plain
    return [worlds.get_generic $fonts_plain fontPlain FontPlain FontPlain]
}

proc fonts.bold {} {
    global fonts_bold
    return [worlds.get_generic $fonts_bold fontBold FontBold FontBold]
}

proc fonts.header {} {
    global fonts_header
    return [worlds.get_generic $fonts_header fontHeader FontHeader FontHeader]
}

proc fonts.italic {} {
    global fonts_italic
    return [worlds.get_generic $fonts_italic fontItalic FontItalic FontItalic]
}
