

proc xmcp11.do_xmcp-who* {} {
	if { [xmcp11.authenticated] == 1 } {
		request.set current xmcp11_multiline_procedure "xmcp-who*"
	}
}

proc xmcp11.do_callback_xmcp-who* {} {
	set which	[request.current]
	set lines	[request.get $which _lines]

	set w [who.create]
	who.refresh $w $lines
}

proc who.create {} {

	global who_view who_lines
	set w .xmcp11_who
	if { [winfo exists $w] == 0 } {

		set who_view user
		set who_lines {}

		toplevel $w
		$w configure -bd 0 -menu $w.menu

		wm title $w "@xwho"

		menu $w.menu
		$w.menu add cascade -label "View" -menu $w.menu.view \
			-underline 0
		menu $w.menu.view -tearoff 0
		$w.menu.view add command \
			-label "by User" -underline 3 \
			-command "who.view_by $w user"
		window.hidemargin $w.menu.view
		$w.menu.view add command \
			-label "by Location" -underline 3 \
			-command "who.view_by $w location"
		window.hidemargin $w.menu.view
		$w.menu.view add separator
		$w.menu.view add command \
			-label "Close" -underline 0 \
			-command "destroy $w"
		window.hidemargin $w.menu.view


		ttk::frame $w.c -bd 0
		window.toolbar_look $w.c
		ttk::label $w.c.l -text ""
		pack configure $w.c.l -side right


		text $w.t -highlightthickness 0 \
			-setgrid 1 \
				-bd 0 \
			-background "#dbdbdb" \
			-cursor {} \
			-relief flat \
			-height 10 -width 20 \
			-font [fonts.fixedwidth] \
			-yscrollcommand "$w.s set"

		ttk::scrollbar $w.s -command "$w.t yview"
		window.set_scrollbar_look $w.s

		who.repack $w

		$w.t tag configure idle_30 -foreground [colourdb.get darkblue]
		$w.t tag configure idle_60 -foreground "#3333cc"
		$w.t tag configure idle_90 -foreground DodgerBlue3
		$w.t tag configure idle_120 -foreground SteelBlue3
		$w.t tag configure idle_300 -foreground SteelBlue2
		$w.t tag configure idle_600 -foreground SteelBlue1
		$w.t tag configure new_user -foreground red
	}
	return $w
}


proc who.repack w {
	catch {
		pack forget [pack slaves $w]
	}
	pack configure $w.c -side top -fill x
	pack configure $w.s -side right -fill y
	pack configure $w.t -side left -expand 1 -fill both
}


proc who.view_by { w view } {
	global who_view who_lines
	set who_view $view
	who._refresh_by_$view $w $who_lines
}

proc who.new_users { old new } {
	if { $old == {} } {
		return {}
	}

	set oldp {}
	set newp {}

	foreach item $old {
		lappend oldp [lindex $item 1]
	}

	foreach item $new {
		set p [lindex $item 1]
		if { [lsearch $oldp $p] == -1 } {
			lappend newp $p
		}
	}

	return $newp
}

proc who.refresh { w lines } {
	global who_lines who_view who_new_users
	set new_lines [who.lines_to_list $lines] 
	set who_new_users [who.new_users $who_lines $new_lines]
	set who_lines $new_lines
	who._refresh_by_$who_view $w $who_lines

	if { [winfo exists .map] == 1 } {
		map.show_people $new_lines
	}
}

proc who.lines_to_list lines {
	foreach line $lines {
		catch { unset foo }

		set foo(idle) 0
		set foo(name) ""
		set foo(location) ""
		set foo(poid) 0
		set foo(loid) 0

		util.populate_array foo $line
		lappend my_lines [list $foo(idle) $foo(name) $foo(location) $foo(poid) $foo(loid)]
	}
	return $my_lines
}

proc who._refresh_by_user { w lines } {
	global who_new_users
	$w.t configure -state normal
	$w.t delete 1.0 end

	set CR ""
	foreach item [lsort -command who.compare_user_idle $lines] {
	if { [lsearch $who_new_users [lindex $item 1]] != -1 } {
		set colour new_user
	} {
		set colour [who.colour [lindex $item 0]]
	}
		$w.t insert insert "$CR[lindex $item 1]" $colour
	set CR "\n"
	}

	$w.t configure -state disabled
	$w.t configure -width 20

	set length [llength $lines]
	if { $length == 1 } {
		$w.c.l configure -text "1 user"
	} {
		$w.c.l configure -text "$length users"
	}

	who.repack $w
}

proc who.colour idle {
	set colour idle_30
	if { $idle > 60 } {
		set colour idle_60
	}
	if { $idle > 90 } {
		set colour idle_90
	}
	if { $idle > 120 } {
		set colour idle_120
	}
	if { $idle > 300 } {
		set colour idle_300
	}
	if { $idle > 600 } {
		set colour idle_600
	}
	return $colour
}

proc who._refresh_by_location { w lines } {
	global room_idle who_new_users
	$w.t configure -state normal
	$w.t delete 1.0 end

	catch { unset room_idle }
	foreach item $lines {
		set room [lindex $item 2]
		set idle [lindex $item 0]
		if { [info exists room_idle($room)] == 0 } {
			set room_idle($room) $idle
		} {
			if { $idle < $room_idle($room) } {
				set room_idle($room) $idle
			}
		}
	}

	set CR ""
	set last_room ""
	foreach item [lsort -command who.compare_room_idle $lines] {
		set idle [lindex $item 0]
		set user [lindex $item 1]
		set user "$user							  "
		set user [string range $user 0 19]

		set room [lindex $item 2]
		if { $room == $last_room } {
			set room ""
		} {
			set last_room $room
		}
		set room "$room							  "
		set room [string range $room 0 19]

		$w.t insert insert "$CR$room " [who.colour $room_idle([lindex $item 2])]
		if { [lsearch $who_new_users [lindex $item 1]] != -1 } {
			set colour new_user
		} {
			set colour [who.colour [lindex $item 0]]
		}
			$w.t insert insert "$user" $colour
		set CR "\n"
	}

	set length [llength $lines]
	if { $length == 1 } {
		$w.c.l configure -text "1 user"
	} {
		$w.c.l configure -text "$length users"
	}

	$w.t configure -state disabled
	$w.t configure -width 41
	who.repack $w
}

proc who.compare_user_idle { this that } {
	if { [lindex $this 0] > [lindex $that 0] } {
		return 1;
	};
	return -1
}

proc who.compare_room_idle { this that } {
	global room_idle
	if { $room_idle([lindex $this 2]) > $room_idle([lindex $that 2]) } {
		return 1;
	};
	if { $room_idle([lindex $this 2]) == $room_idle([lindex $that 2]) } {

		if { [lindex $this 0] > [lindex $that 0] } {
			return 1;
		};
		return -1
	};
	if { $room_idle([lindex $this 2]) < $room_idle([lindex $that 2]) } {
		return -1;
	};
}
#
#
