proc default.default {} {
    set menu .menu.prefs
    $menu.fonts invoke "fixedwidth"
    $menu.bindings invoke "windows"
}

proc default.options {} {
    option add *Text.background #f0f0f0 userDefault
    option add *Entry.background #d3b6b6 userDefault
    option add *desktopBackground #d9d9d9 userDefault
    option add *BorderWidth 1 userDefault
}
