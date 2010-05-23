

set colourdb_colours(red) 	"#fb1441"
set colourdb_colours(orange) 	"#ffa600"
set colourdb_colours(yellow) 	"#ffff00"
set colourdb_colours(green) 	"#3cfb34"
set colourdb_colours(darkgreen) "#006500"
set colourdb_colours(lightblue)	"#c3e3e3"
set colourdb_colours(blue) 	"#5151fb"
set colourdb_colours(darkblue) 	"#00008a"
set colourdb_colours(black) 	"#000000"
set colourdb_colours(grey) 	"#dbdbdb"
set colourdb_colours(white) 	"#ffffff"
set colourdb_colours(pink) 	"#d3b6b6"

set colourdb_colours(magenta)	"#ff00ff"
set colourdb_colours(cyan)	"#00ffff"

proc colourdb.get colour {
	global colourdb_colours
	set col ""
	catch { set col $colourdb_colours($colour) };
	if { $col == "" } {
		puts "colourdb.get, colour '$colour' unknown"
		set col black
	}
	return $col
}
#
#
