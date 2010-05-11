client.register bwindow start 
proc bwindow.start {} {
	edittriggers.register_alias bwindow.display bwindow.display
}

proc bwindow.display {name {text ""}} {
	global subwindow_db
	if { [info exists subwindow_db($name:win)] &&
			[winfo exists $subwindow_db($name:win)] } {
		set win $subwindow_db($name:win)
		set CR "\n"
	} {
		# window doesn't exist, create one
		set win .[util.unique_id subwindow]
		set subwindow_db($name:win) $win
		set subwindow_db($win:name) $name
		toplevel $win
		wm iconname $win $name
		wm title $win $name
		text $win.t -width 40 -height 10 \
			-highlightthickness 0 \
			-relief flat \
			-yscrollcommand "$win.s set"
		scrollbar $win.s \
			-bd 1 -highlightthickness 0 \
			-command "$win.t yview"
		pack $win.s -side right -fill y
		pack $win.t -fill both -expand 1
		window.place_nice $win
		set CR ""
	}
	$win.t configure -state normal
	$win.t insert end "$CR$text"
	$win.t configure -state disabled
	$win.t yview -pickplace end
}

