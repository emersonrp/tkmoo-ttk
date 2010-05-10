


proc default.default {} {
	set menu .menu.prefs
	$menu.fonts invoke "fixedwidth"
	$menu.bindings invoke "windows"
}

proc default.options {} {
	global tcl_platform
	option add *Text.background #f0f0f0 userDefault
	option add *Entry.background #d3b6b6 userDefault
	option add *desktopBackground #d9d9d9 userDefault
	option add *BorderWidth 1 userDefault
	if { $tcl_platform(platform) == "macintosh" } {
		option add *Text.insertWidth 2 userDefault
		option add *Entry.insertWidth 2 userDefault
	}
	if { $tcl_platform(platform) == "macintosh" } {
		option add *Frame.background #cccccc userDefault
		option add *Label.background #cccccc userDefault
		option add *Toplevel.background #cccccc userDefault
		option add *Checkbutton.background #cccccc userDefault
		option add *Radiobutton.background #cccccc userDefault
		option add *Menubutton.background #cccccc userDefault
		option add *Scale.background #cccccc userDefault
		option add *Text.highlightbackground #cccccc userDefault
    }
}
#
#

