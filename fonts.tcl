


set fonts_plain      "-*-times-medium-r-*-*-14-*-*-*-*-*-*-*"
set fonts_fixedwidth "7x14"
set fonts_bold       "-*-times-bold-r-*-*-14-*-*-*-*-*-*-*"
set fonts_italic     "-*-times-medium-i-*-*-14-*-*-*-*-*-*-*"
set fonts_header     "-*-helvetica-medium-o-normal-*-18-*-*-*-*-*-*-*"

switch $tcl_platform(platform) {
    windows {
        if { $tk_version >= 8.0 } {
            set fonts_plain      {helvetica 8}
            set fonts_fixedwidth {courier 8}
            set fonts_bold       {helvetica 8 bold}
            set fonts_italic     {helvetica 8 italic}
            set fonts_header     {helvetica 10 bold italic}
        }
    }
    unix - default {
        if { $tk_version >= 8.0 } {
            set fonts_plain      {helvetica 12}
            set fonts_fixedwidth {courier 12}
            set fonts_bold       {helvetica 12 bold}
            set fonts_italic     {helvetica 12 italic}
            set fonts_header     {helvetica 14 bold italic}
        }
    }
}

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
#
#
#
