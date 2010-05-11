
proc window.clear_tagging_info {} {
	global window_tagging_info
	set window_tagging_info {}
}
proc window.append_tagging_info record {
	global window_tagging_info
	lappend window_tagging_info $record
}
proc window.assert_tagging_info line {
	global window_tagging_info
	set last_char [.output index {end - 1 char}]
	foreach {num _} [split $last_char "."] { break }
	foreach record $window_tagging_info {
		foreach {the_line tag_list} $record { break }
		if { $line == $the_line } {
			foreach tag_record $tag_list {
				foreach {from to tags} $tag_record { break }
				foreach tag $tags {
					.output tag add $tag $num.$from $num.$to
				}
			}
		}
	}
}

proc window.place_absolute {win x y} {
	wm geometry $win "+$x+$y"
}
proc window.place_nice {this {that ""}} {
	if { $that != "" } {
		set x [winfo rootx $that]
		set y [winfo rooty $that]
		incr x 50
		incr y 50
		window.place_absolute $this $x $y
	} {
		window.place_absolute $this 50 50
	}
}

proc window.set_geometry {win geometry} {
	pack propagate . 1
	wm geometry $win $geometry
	update
	pack propagate . 0
}

proc window.bind_escape_to_destroy win {
	global tcl_platform
	if { $tcl_platform(platform) != "macintosh" } {
		bind $win <Escape> "destroy $win"
	}
}

proc window.configure_for_macintosh win {
	global tcl_platform
	if { $tcl_platform(platform) != "macintosh" } {
		return;
	}
   	set mac _macintosh
   	if { $win != "." } {
		set mac "._macintosh"
	}

	set topline "_topline"
	set cell "_cell"
	if { [winfo exists $win$mac$topline] } {
		return;
	}

	frame $win$mac$topline \
		-height 1 \
		-borderwidth 0 \
		-highlightthickness 0 \
		-background #000000
	frame $win$mac$cell \
		-height 14 \
		-borderwidth 0 \
		-highlightthickness 0 \
		-background #cccccc
	window.pack_for_macintosh $win
}

proc window.pack_for_macintosh win {
	global tcl_platform
	if { $tcl_platform(platform) != "macintosh" } {
		return;
	}
	set mac _macintosh
	if { $win != "." } {
		set mac "._macintosh"
	}
	set topline "_topline"
	set cell "_cell"
	pack $win$mac$cell \
		-side bottom \
		-fill x \
		-in $win
	pack $win$mac$topline \
		-side bottom \
		-fill x \
		-in $win
}

proc window.iconify {} {
	if { [winfo viewable .] } {
		wm iconify .
	}
}

proc window.deiconify {} {
	if { ! [winfo viewable .] } {
		wm deiconify .
	}
}

proc window.initialise_text_widget w {
	global window_db
	set window_db("$w,window_CR") 0
}

set window_CR 0

set window_input_size 1
set window_input_size_display 1

set window_close_state disabled

proc window.hidemargin menu {
	global tcl_platform
	if { $tcl_platform(platform) == "windows" } {
		return
	}
	if { $tcl_platform(platform) == "macintosh" } {
		return
	}
	if { ([util.eight] == 1) && ([$menu type end] != "separator") } {
		$menu entryconfigure end -hidemargin 1
	}
}

proc window.save_layout {} {
	set world [worlds.get_current]
	if { $world == "" } { return }

	set worlds_geometry [worlds.get_generic "=50x24" {} {} WindowGeometry]
	set actual_geometry [wm geometry .]
	if { $worlds_geometry != $actual_geometry } {
		worlds.set $world WindowGeometry $actual_geometry
	}
}

client.register window start
proc window.start {} {
	global window_clip_output_buffer
	set window_clip_output_buffer 0
	preferences.register window {Special Forces} {
		{ {directive UnderlineHyperlinks}  
			  {type choice-menu}
			  {default hover}
			  {display "Underline hyperlinks"}
			  {choices {never hover always}} }
		{ {directive HyperlinkForeground}  
			  {type colour}
			  {default "#0000ee"}
			  {default_if_empty}
			  {display "Link colour"}}
		{ {directive WindowClipBuffer}  
			  {type boolean}
			  {default Off}
			  {display "Limit output window"} }
		{ {directive WindowClipBufferSize}  
			  {type updown-integer}
			  {default 500}
			  {display "Output window size"}
			  {low 500}
			  {delta 500}
		  {high 100000}}
	}

	preferences.register window {Paragraph Layout} {
		{ {directive UseParagraph}  
			  {type boolean}
			  {default On}
			  {display "Display paragraphs"} }
		{ {directive ParagraphUnits}
			  {type choice-menu}
			  {default pixels}
			  {display "Distance units"}
			  {choices {pixels millimeters characters}} }
		{ {directive ParagraphLMargin}
			  {type updown-integer}
			  {default 0}
			  {display "Left margin"}
			  {low 0}
		  {high 50}}
		{ {directive ParagraphLIndent}
			  {type updown-integer}
			  {default 3}
			  {display "2nd line indent"}
			  {low 0}
		  {high 100}}
		{ {directive ParagraphRMargin}
			  {type updown-integer}
			  {default 0}
			  {display "Right margin"}
			  {low 0}
		  {high 50}}
		{ {directive ParagraphSpacing1}
			  {type updown-integer}
			  {default 0}
			  {display "Space above"}
			  {low 0}
		  {high 10}}
		{ {directive ParagraphSpacing2}
			  {type updown-integer}
			  {default 0}
			  {display "Space between"}
			  {low 0}
		  {high 10}}
		{ {directive ParagraphSpacing3}
			  {type updown-integer}
			  {default 0}
			  {display "Space below"}
			  {low 0}
		  {high 10}}
	}
	preferences.register window {Statusbar Settings} {
		{ {directive ShowStatusbars}
			  {type boolean}
			  {default On}
			  {display "Show statusbars"} }
		{ {directive UseActivityFlash}
			  {type boolean}
			  {default On}
			  {display "Activity flash light"} }
		{ {directive KioskTimeout}
			  {type updown-integer}
			  {default 0}
			  {low 0}
			  {high 30}
			  {display "Kiosk after seconds"} }
	}
}


set window_activity_flash 0
set window_activity_toggle 0

proc window.activity_flash {} {
	global window_activity_flash window_activity_toggle \
	   window_activity_flash_colour window_flash
	if { [winfo exists $window_flash] == 0 } { return }
	if { $window_activity_flash == 0 } {
		$window_flash.light configure -background $window_activity_flash_colour
		return
	}
	if { [window._last_char_is_visible] == 1 } {
		$window_flash.light configure -background $window_activity_flash_colour
		set window_activity_flash 0
		set window_activity_toggle 0
		return
	}
	if { $window_activity_toggle == 1 } {
		$window_flash.light configure -background red
		set window_activity_toggle 0
	} {
		$window_flash.light configure -background $window_activity_flash_colour
		set window_activity_toggle 1
	}
	after 500 window.activity_flash
}

proc window.activity_begin_flashing {} {
	global window_activity_flash
	
	if { $window_activity_flash == 0 } {
		set window_activity_flash 1
		window.activity_flash
	}
}
proc window.activity_stop_flashing {} {
	global window_activity_flash window_activity_toggle
	set window_activity_flash 0
}

set window_toolbars {}
proc window.add_toolbar toolbar {
	global window_toolbars
	if { [lsearch -exact $window_toolbars $toolbar] == -1 } {
		lappend window_toolbars $toolbar
	}
}
set window_sidebars {}
proc window.add_sidebar sidebar {
	global window_sidebars
	if { [lsearch -exact $window_sidebars $sidebar] == -1 } {
		lappend window_sidebars $sidebar
	}
}
proc window.remove_toolbar toolbar {
	global window_toolbars
	set index [lsearch -exact $window_toolbars $toolbar]
	if { $index != -1 } {
		set window_toolbars [lreplace $window_toolbars $index $index]
	}
}
proc window.remove_sidebar sidebar {
	global window_sidebars
	set index [lsearch -exact $window_sidebars $sidebar]
	if { $index != -1 } {
		set window_sidebars [lreplace $window_sidebars $index $index]
	}
}

set window_statusbars {}
proc window.add_statusbar statusbar {
	global window_statusbars
	if { [lsearch -exact $window_statusbars $statusbar] == -1 } {
	if { $statusbar == ".statusbar" } {
		set window_statusbars [linsert $window_statusbars 0 $statusbar]
	} {
			lappend window_statusbars $statusbar
	}
	}
}
proc window.remove_statusbar statusbar {
	global window_statusbars
	set index [lsearch -exact $window_statusbars $statusbar]
	if { $index != -1 } {
		set window_statusbars [lreplace $window_statusbars $index $index]
	}
}




proc window.statusbar_create {} {
	if { [winfo exists .statusbar] == 1 } { return }
	global window_statusbar_message
	set window_statusbar_message ""
	frame .statusbar -bd 1 -relief sunken -highlightthickness 0
	window.add_statusbar .statusbar
	label .statusbar.messages \
		-text "" \
		-highlightthickness 0 \
		-bd 1 \
		-relief raised \
		-justify left \
		-anchor w \
		-bg lightblue 
	pack .statusbar.messages -side left -expand 1 -fill x
	bind .statusbar.messages <Configure> "window.statusbar_messages_repaint"
	window.repack
}

proc window.statusbar_destroy {} {
	catch { destroy .statusbar }
	window.remove_statusbar .statusbar
}


proc window.truncate_for_label {label text} {
	set width [winfo width $label]
	set padx [$label cget -padx]
	set font [$label cget -font]
	set measure [font measure $font -displayof $label $text]
	if { $measure < [expr $width - 4*$padx] } {
		return $text
	}
	for {set i [string length $text]} {$i > 0} { incr i -1 } {
		set trial "[string trimright [string range $text 0 $i]]..."
		set measure_trial [font measure $font -displayof $label $trial]
		if { $measure_trial < [expr $width - 4*$padx] } {
			set text $trial 
			break
		}   
	}
	if { $i == 0 } {
		return ""
	}
	return $text
}

proc window.statusbar_messages_repaint {} {
	global window_statusbar_message
	.statusbar.messages configure \
		-text [window.truncate_for_label .statusbar.messages $window_statusbar_message]
}

proc window.set_status {text {type decay}} {
	global window_statusbar_current_task_id window_statusbar_message
	window.statusbar_create
	set window_statusbar_message $text
	window.statusbar_messages_repaint
	catch { 
		after cancel $window_statusbar_current_task_id 
	}
	if { $type == "decay" } {
		set window_statusbar_current_task_id [after 20000 window.statusbar_decay]
	}
}

proc window.statusbar_decay {} {
	window.set_status "" stick
}

proc window.create_statusbar_item {} {
	window.statusbar_create
	set item .statusbar.[util.unique_id "item"]
	return $item
}
proc window.delete_statusbar_item item {
	destroy $item
}
proc window.clear_status_if_present {} {
	if { [winfo exists .statusbar] == 1 } {
		.statusbar.messages configure -text ""
	}
}

proc window.client_connected {} {
	global window_close_state window_fonts tkmooVersion
	set window_close_state normal

	.menu.connections entryconfigure "Close" -state normal

	set size [worlds.get_generic 1 {} {} InputSize]

	if { $size < 1 } { set size 1 };
	if { $size > 5 } { set size 5 };
	after idle window.input_resize $size

	set fg [worlds.get_generic "#000000" foreground Foreground ColourForeground]

	if { $fg != "" } {
		.output configure -foreground $fg 
	}

	set bg [worlds.get_generic "#f0f0f0" background Background ColourBackground]

	if { $bg != "" } {
		.output configure -background $bg
	}

	set fg [worlds.get_generic "#000000" foregroundinput ForegroundInput ColourForegroundInput]

	if { $fg != "" } {
		.input configure -foreground $fg 
	}

	set bg [worlds.get_generic [colourdb.get pink] backgroundinput BackgroundInput ColourBackgroundInput]

	if { $bg != "" } {
		.input configure -background $bg
	}

	set font [worlds.get_generic fixedwidth background DefaultFont DefaultFont]

	if { $font != "" } {
		set window_fonts $font
	}
	window.reconfigure_fonts

	catch { wm title . "[worlds.get [worlds.get_current] Name] - tkMOO-SE v$tkmooVersion" }
	catch { wm iconname . [worlds.get [worlds.get_current] Name] }

	set lm	  [worlds.get_generic 0 {} {} ParagraphLMargin]
	set in	  [worlds.get_generic 3 {} {} ParagraphLIndent]
	set rm	  [worlds.get_generic 0 {} {} ParagraphRMargin]
	set s_one   [worlds.get_generic 0 {} {} ParagraphSpacing1]
	set s_two   [worlds.get_generic 0 {} {} ParagraphSpacing2]
	set s_three [worlds.get_generic 0 {} {} ParagraphSpacing3]
	set units   [worlds.get_generic pixels {} {} ParagraphUnits]

	set xxx(pixels)	  p
	set xxx(millimeters) m
	set xxx(characters)  c
	set units $xxx($units)

	set use [worlds.get_generic on {} {} UseParagraph]

	if { [string tolower $use] == "on" } {
		set paragraphs 1
	} {
		set paragraphs 0
	}

	if { $paragraphs == 1 } {

		eval .output tag configure window_margin -lmargin1 [join "$lm $units" {}] -lmargin2 [join "$in $units" {}] -rmargin [join "$rm $units" {}] -spacing1 [join "$s_one $units" {}] -spacing2 [join "$s_two $units" {}] -spacing3 [join "$s_three $units" {}]

	} {

		.output tag configure window_margin -lmargin1 0 -lmargin2 0 -rmargin 0 -spacing1 0 -spacing2 0 -spacing3 0

	}

	set show_statusbars [worlds.get_generic "On" {} {} ShowStatusbars]
	if { [string tolower $show_statusbars] == "on" } {
		window.set_statusbar_flag 1
	} {
		window.set_statusbar_flag 0
	}

	window.statusbar_destroy

	set use_flash [worlds.get_generic On {} {} UseActivityFlash]
	if { [string tolower $use_flash] == "on" } {
		window.make_flash
	} {
		window.destroy_flash
	}


	set resize [worlds.get_generic 0 {} {} WindowResize]
	if { $resize } {

		set geometry [worlds.get_generic "=80x24+100+100" {} {} WindowGeometry]

		if { $geometry != "" } {
			if { [regexp {^=*[0-9]*x[0-9]*[+-][0-9]*[+-][0-9]*$} $geometry unused gx gy] == 1 } {
					after idle window.set_geometry . $geometry
			}
		} {
		window.place_nice .
	}
	}
	window.menu_preferences_state "Edit Preferences..." normal
	window.repack

	global window_clip_output_buffer window_clip_output_buffer_size
	set use_clip [worlds.get_generic Off {} {} WindowClipBuffer]
	if { [string tolower $use_clip] == "on" } {
		set window_clip_output_buffer 1
	} {
		set window_clip_output_buffer 0
	}
	set window_clip_output_buffer_size [worlds.get_generic Off {} {} WindowClipBufferSize]
}

set window_flash 0
proc window.make_flash {} {
	global window_flash window_activity_flash_colour
	if { [winfo exists $window_flash] == 1 } { return };
	set window_flash [window.create_statusbar_item]
	frame $window_flash -bd 0 -highlightthickness 0 -relief raised
	pack $window_flash -side right -fill both
	frame $window_flash.light -bd 1 -height 10 -width 6 -relief raised
	$window_flash.light configure -background pink
	set window_activity_flash_colour [$window_flash.light cget -background]
	pack $window_flash.light -expand 1 -fill y
}
proc window.destroy_flash {} {
	global window_flash
	window.delete_statusbar_item $window_flash
}

proc window.client_disconnected {} {
	global window_close_state tkmooVersion
	set window_close_state disabled
	window.displayCR "Connection closed" window_highlight
	wm title	. "tkMOO-SE v$tkmooVersion"
	wm iconname . "tkMOO-SE v$tkmooVersion"
	window.clear_status_if_present
	window.menu_preferences_state "Edit Preferences..." disabled
	.menu.connections entryconfigure "Close" -state disabled
}

proc window.do_open {} {
	set host [string trim [.open.entries.host get]]
	set port [string trim [.open.entries.port get]]
	if { $host != "" && $port != "" } {
		destroy .open
		client.connect $host $port 
	}
}

proc window.open {} {
	catch { destroy .open };
	toplevel .open
	window.configure_for_macintosh .open

	window.place_nice .open

	.open configure -bd 0

	wm title .open "Open Connection"
	ttk::frame .open.entries
	ttk::label .open.entries.h -text "Host:"
	ttk::entry .open.entries.host -font [fonts.fixedwidth]
	ttk::label .open.entries.p -text "Port:"
	ttk::entry .open.entries.port \
		-width 4 \
		-font [fonts.fixedwidth]
	pack .open.entries.h -side left
	pack .open.entries.host -side left
	pack .open.entries.p -side left
	pack .open.entries.port -side left

	ttk::frame .open.buttons

	ttk::button .open.buttons.connect -text "Connect" \
		-command { window.do_open }

	bind .open <Return> { window.do_open };
	window.bind_escape_to_destroy .open

	ttk::button .open.buttons.cancel -text "Cancel" -command "destroy .open"

	pack .open.entries
	pack .open.buttons

	pack .open.buttons.connect .open.buttons.cancel -side left -padx 5 -pady 5
	window.focus .open.entries.host
}

proc window.menuise_worlds {} {
	catch {
		.menu.connections.menu delete 5 end
	}
	.menu.connections.menu add separator
	set hints [split 0123456789abdfghijklmnprstuvwxyz {}]
	foreach world [worlds.worlds] { 
	set hint [lindex $hints 0]
	set hints [lrange $hints 1 end]
		.menu.connections.menu add command \
		-label   "$hint. [worlds.get $world Name]"\
		-underline 0 \
		-command "client.connect_world \"$world\""
	}
}

proc window.do_disconnect {} {
	set session ""
	catch {
		set session [db.get .output session]
	}
	if { $session != "" } {
		client.disconnect_session $session
	}
}

proc window.post_connect {} {
	global tcl_platform
	set menu .menu.connections

	global window_close_state

	$menu delete 0 end

	$menu add command \
		-label "Worlds..." \
		-underline 0 \
		-command "window.open_list"
		window.menu_macintosh_accelerator $menu "Worlds..." "Cmd+W"
		window.hidemargin $menu

	$menu add command \
		-label "Open..." \
		-underline 0 \
		-command "window.open"
		window.menu_macintosh_accelerator $menu "Open..." "Cmd+O"
		window.hidemargin $menu

	$menu add command \
		-label "Close" \
		-underline 0 \
		-command "window.do_disconnect"
		window.menu_macintosh_accelerator $menu Close "Cmd+K"
		window.hidemargin $menu

	$menu entryconfigure "Close" -state $window_close_state

	$menu add separator

	if { $tcl_platform(platform) == "macintosh" } {
		set hints [split 0123456789 {}]
	} {
		set hints [split 0123456789abdefghijklmnprstuvxyz {}]
	}


	foreach world [worlds.worlds] {
	if { $world != 0 } {
		set shortlist ""
		catch { set shortlist [worlds.get_generic "Off" {} {} ShortList $world] }

		if { [string tolower $shortlist] == "on" } {
			set hint [lindex $hints 0]
			set hints [lrange $hints 1 end]
		if { $tcl_platform(platform) == "macintosh" } {
			set label [worlds.get $world Name]
		} {
			set label "$hint. [worlds.get $world Name]"
		}
				$menu add command \
					-label $label \
					-underline 0 \
					-command "client.connect_world $world"
				window.menu_macintosh_accelerator $menu end "Cmd+$hint"
				window.hidemargin $menu
		}
	}
	}

	$menu add separator
	$menu add command \
		-label "Quit" \
		-underline 0 \
		-command "client.exit"

	window.hidemargin $menu
}

proc window.load_connections_menu {} {
	if { [worlds.load] == 1 } {
		set worlds [worlds.worlds]
		window.menuise_worlds
	}
}

proc window.configure_help_menu {} {
	set menu .menu.help
	$menu delete 0 end
	foreach subject [help.subjects] {
		if { $subject == "SEPARATOR" } {
		$menu add separator
		} {
			$menu add command \
				-label   "[help.get_title $subject]" \
				-command "help.show $subject"
			window.hidemargin $menu
		}
	}
}


proc window.menu_help_add { text {command ""} } {
	set menu .menu.help
	if { $text == "SEPARATOR" } {
		$menu add separator
	} {
		$menu add command \
			-label   "$text" \
			-command $command
		window.hidemargin $menu
	}
}

proc window.menu_help_state { text state } {
	.menu.help entryconfigure $text -state $state
}

proc window.menu_tools_macintosh_accelerator { text accelerator } {
	set menu .menu.tools
	window.menu_macintosh_accelerator $menu $text $accelerator
}

proc window.menu_tools_add { text {command ""} } {
	set menu .menu.tools
	if { $text == "SEPARATOR" } {
		$menu add separator
	} {
		$menu add command \
			-label   "$text" \
			-command $command
		window.hidemargin $menu
	}
}

proc window.menu_tools_add_cascade { text cascade } {
	set menu .menu.tools
	$menu add cascade \
		-label   "$text" \
		-menu $cascade
	window.hidemargin $menu
}

proc window.menu_tools_state { text state } {
	.menu.tools entryconfigure $text -state $state
}

proc window.menu_preferences_macintosh_accelerator { text accelerator } {
	set menu .menu.prefs
	window.menu_macintosh_accelerator $menu $text $accelerator
}

proc window.menu_preferences_state { text state } {
	.menu.prefs entryconfigure $text -state $state
}

proc window.menu_preferences_add { text {command ""} } {
	set menu .menu.prefs
	if { $text == "SEPARATOR" } {
		$menu add separator
	} {
		$menu add command \
			-label   "$text" \
			-command $command
		window.hidemargin $menu
	}
}

proc window.reconfigure_fonts {} {
	global window_fonts
	switch $window_fonts {
	fixedwidth {
		.output configure -font [fonts.fixedwidth]
		.input configure -font [fonts.fixedwidth]
	}
	proportional {
		.output configure -font [fonts.plain]
		.input configure -font [fonts.plain]
	}
	}
}

proc window.resize_event {} {
	global window_resize_event_task
	catch { after cancel $window_resize_event_task }
	set window_resize_event_task [after idle {
		window.save_layout
	}]
}

proc window.menu_macintosh_accelerator {menu pattern accelerator} {
	global tcl_platform
	if { $tcl_platform(platform) == "macintosh" } {
		$menu entryconfigure $pattern -accelerator $accelerator
	}
}

###
proc window.set_local_echo_from_menu {} {
	global client_echo
	if { $client_echo } {
		set value On
	} {
		set value Off
	}
	if { [set world [worlds.get_current]] != "" } {
		worlds.set_if_different $world LocalEcho $value
	}
}

proc window.set_client_mode_from_menu {} {
	global client_mode
	if { [set world [worlds.get_current]] != "" } {
		worlds.set_if_different $world ClientMode $client_mode
	}
}

proc window.set_key_bindings_from_menu {} {
	global window_binding
	if { [set world [worlds.get_current]] != "" } {
		worlds.set_if_different $world KeyBindings $window_binding
	}
	bindings.set $window_binding
}

proc window.set_default_font_from_menu {} {
	global window_fonts
	if { [set world [worlds.get_current]] != "" } {
		worlds.set_if_different $world DefaultFont $window_fonts
	}
	client.reconfigure_fonts
}

proc window.set_input_size_from_menu {} {
	global window_input_size_display
	if { [set world [worlds.get_current]] != "" } {
		worlds.set_if_different $world InputSize $window_input_size_display
	}
	window.input_resize $window_input_size_display
}

proc window.toggle_statusbar_from_menu {} {
	window.toggle_statusbar
	if { [set world [worlds.get_current]] != "" } {
		if { [window.get_statusbar_flag] } {
			set flag On
		} {
			set flag Off
		}
		worlds.set_if_different $world ShowStatusbars $flag
	}
}
#
###

proc window.buildWindow {} {
	window.set_statusbar_flag 1
	global tkmooVersion client_mode client_echo \
		window_activity_flash_colour window_flash

	wm title	. "tkMOO-SE v$tkmooVersion"
	wm iconname . "tkMOO-SE v$tkmooVersion"
	. configure -bd 0

	window.configure_for_macintosh .

	menu .menu -bd 0 -tearoff 0 -relief raised -bd 1
	. configure -menu .menu

	.menu add cascade -label "Connect" -menu .menu.connections \
		 -underline 0

	 menu .menu.connections -tearoff 0 -bd 1

	.menu add cascade -label "Edit" -underline 0 -menu .menu.edit
	menu .menu.edit -tearoff 0 -bd 1
	.menu.edit add command -label "Cut" \
		-command "ui.delete_selection .input" \
		-accelerator "[window.accel Ctrl]+X"
	window.hidemargin .menu.edit
	.menu.edit add command -label "Copy" \
		-command "ui.copy_selection .input" \
		-accelerator "[window.accel Ctrl]+C"
	window.hidemargin .menu.edit
	.menu.edit add command -label "Paste" \
		-command "ui.paste_selection .input" \
		-accelerator "[window.accel Ctrl]+V"
	window.hidemargin .menu.edit
	.menu.edit add separator
	.menu.edit add command -label "Clear" \
		-underline 1 \
		-command "ui.clear_screen .output"
	window.menu_macintosh_accelerator .menu.edit Clear "Cmd+L"
	window.hidemargin .menu.edit

	.menu add cascade -label "Tools" -underline 0 -menu .menu.tools
	menu .menu.tools -tearoff 0 -bd 1

	.menu add cascade -label "Preferences" -underline 0 -menu .menu.prefs
	menu .menu.prefs -tearoff 0 -bd 1

	window.menu_preferences_add "Toggle Statusbars" \
	window.toggle_statusbar_from_menu

	.menu.prefs add cascade -label "Key Bindings" \
		 -menu .menu.prefs.bindings
	window.hidemargin .menu.prefs
	menu .menu.prefs.bindings -tearoff 0

	foreach binding [bindings.bindings] {
		.menu.prefs.bindings add radio \
			-variable window_binding \
			-value $binding \
			-label "$binding" \
			-command "window.set_key_bindings_from_menu"
	}


	.menu.prefs add cascade \
		-label "Default Font" -menu .menu.prefs.fonts
	window.hidemargin .menu.prefs

	menu .menu.prefs.fonts -tearoff 0

	foreach font {fixedwidth proportional} {
		.menu.prefs.fonts add radio \
				-variable window_fonts \
				-value $font \
				-label "$font" \
				-command window.set_default_font_from_menu
	}

	.menu.prefs add cascade -label "Mode" \
		-menu .menu.prefs.mode
	window.hidemargin .menu.prefs
	menu .menu.prefs.mode -tearoff 0

	foreach mode {line character} {
		.menu.prefs.mode add radio \
			-variable client_mode \
			-value $mode \
			-label "$mode" \
			-command "window.set_client_mode_from_menu"
	}


	.menu.prefs add cascade -label "Local Echo" \
		-menu .menu.prefs.local
	window.hidemargin .menu.prefs
	menu .menu.prefs.local -tearoff 0

	.menu.prefs.local add radio \
		-variable client_echo \
		-value 1 \
		-command "window.set_local_echo_from_menu" \
		-label "on"
	.menu.prefs.local add radio \
		-variable client_echo \
		-command "window.set_local_echo_from_menu" \
		-value 0 \
		-label "off"

	.menu.prefs add cascade \
		-label "Input Size" -menu .menu.prefs.size
	window.hidemargin .menu.prefs

	menu .menu.prefs.size -tearoff 0
	for {set i 1} {$i < 6} {incr i} {
		.menu.prefs.size add radio \
			-variable window_input_size_display \
			-value $i \
			-label "$i" \
			-command window.set_input_size_from_menu
	}


	.menu add cascade -label "Help" -underline 0 -menu .menu.help
	menu .menu.help -tearoff 0 -bd 1

	window.configure_help_menu

	global tcl_platform
	if { $tcl_platform(platform) == "windows" } {
		frame .canyon -bd 2 -height 2 -relief sunken
	}

	text .output \
		-cursor {} \
		-font [fonts.fixedwidth] \
		-width 80 \
		-height 24 \
		-setgrid 1 \
		-relief flat \
		-bd 0 \
		-yscrollcommand ".scrollbar set" \
		-highlightthickness 0 \
		-wrap word

	text .input \
		-wrap word \
		-relief sunken \
		-height 1 \
		-highlightthickness 0 \
		-font [fonts.fixedwidth] \
		-background [colourdb.get pink]

	history.init .input 1

	scrollbar .scrollbar \
		-command ".output yview" \
		-highlightthickness 0

	window.repack


	update
	pack propagate . 0

	bind .output <ButtonRelease-2> {
		if {!$tkPriv(mouseMoved)} { window.selection_to_input }
	}
	bindtags .output {Text .output . all}

	.output configure -state disabled

	window.focus .input

	.output tag configure window_margin -lmargin1 0m -lmargin2 3m
	.output tag configure window_highlight -foreground [colourdb.get red]

	bind . <FocusIn> {window.cancel_lite}
	bind . <FocusOut> {window.timeout_lite}

	bind . <Configure> { window.resize_event }

	wm protocol . WM_DELETE_WINDOW client.exit

	global window_clip_output_buffer
	set window_clip_output_buffer 0
	window.hyperlink.init
	window.initialise_text_widget .output
}

proc window.accel str {
	global tcl_platform
	if { $str == "Ctrl" && $tcl_platform(platform) == "macintosh" } {
		return "Cmd"
	}
	return $str
}

proc window.focus win {
	global tcl_platform
	if {
		$tcl_platform(platform) == "windows" ||
		$tcl_platform(platform) == "macintosh"
	} {
		after idle raise [winfo toplevel $win]
	}
	focus $win
}


proc window.cancel_lite {} {
	global window_timeout_lite window_timeout_lite_task

	if { [lsearch -exact [pack slaves .] .input] == -1 } {
		window.repack
	}
	set window_timeout_lite 0
}

proc window.timeout_lite {} {
	global window_timeout_lite window_timeout_lite_task
	if { $window_timeout_lite != 0 } { return };
	set task [util.unique_id task]
	set window_timeout_lite $task
	set timeout [worlds.get_generic 0 {} {} KioskTimeout]
	if { $timeout } {
		set timeout [expr $timeout * 1000]
		set window_timeout_lite_task [after $timeout window.timeout_lite_doit $task]
	}
}

proc window.timeout_lite_doit task {
	global window_timeout_lite
	if { $window_timeout_lite == $task } {
		window.repack_lite
		set window_timeout_lite 0
	}
}

set window_timeout_lite 0
proc window.repack_lite {} {
	global window_toolbars window_statusbars window_sidebars
	set slaves [pack slaves .]
	set tmp [list]
	foreach s $slaves {
		if { $s != ".output" } {
			lappend tmp $s
		}
	}
	set slaves $tmp

	. configure -menu {}

	foreach slave $slaves {
		pack forget $slave
	}
	pack configure .output -side bottom -fill both -expand on
}

#

set window_unsent_cmd [list 0 ""]

proc window.ui_input_return {} {
	global window_unsent_cmd
	set line [.input get 1.0 {end -1 char}]
	after idle ".input delete 1.0 end"
	history.add .input "$line"
	client.outgoing "$line"
	set window_unsent_cmd [list 0 ""]
}

proc window.ui_input_up {} {
	global window_unsent_cmd
	if { [lindex $window_unsent_cmd 0] == 0 } {
		set window_unsent_cmd [list 1 [.input get 1.0 {end -1c}]]
	}
	set prev [history.prev .input]
	.input delete 1.0 end
	.input insert insert $prev
}

proc window.ui_input_down {} {
	global window_unsent_cmd

	set next [history.next .input]
	if { $next == "" } {
		if { [lindex $window_unsent_cmd 0] == 1 } {
			set next [lindex $window_unsent_cmd 1]
			set window_unsent_cmd [list 0 ""]

			.input delete 1.0 end
			.input insert insert $next
		}
	} {
		.input delete 1.0 end
		.input insert insert $next
	}
}


proc window.toggle_statusbar {} {
	window.toggle_statusbar_flag
	window.repack
}

proc window.set_statusbar_flag value {
	global window_statusbar_flag
	set window_statusbar_flag $value
}

proc window.get_statusbar_flag {} {
	global window_statusbar_flag
	return $window_statusbar_flag
}

proc window.toggle_statusbar_flag {} {
	global window_statusbar_flag
	if { $window_statusbar_flag } {
		set window_statusbar_flag 0
	} {
		set window_statusbar_flag 1
	}
}

proc window.repack {} {
	global window_repack_task
	catch { after cancel $window_repack_task }
	set window_repack_task [after idle window.really_repack]
}

proc window.really_repack {} {

	global window_toolbars window_statusbars window_sidebars

	set window_current_position [.output yview]

	foreach slave [pack slaves .] {
		pack forget $slave
	}

	. configure -menu .menu

	window.configure_for_macintosh .
	window.pack_for_macintosh .

	if { [window.get_statusbar_flag] == 1 } {
		foreach statusbar $window_statusbars {
			pack $statusbar -side bottom -fill x -in .
		}
	}

	pack .input -side bottom -fill x -in .

	foreach toolbar $window_toolbars {
		pack $toolbar -side top -fill x -in .
	}
	foreach sidebar $window_sidebars {
		pack $sidebar -side right -fill y -in .
	}

	global tcl_platform
	if { $tcl_platform(platform) == "windows" } {
		pack .canyon -side top -fill x -in .
	}

	pack .scrollbar -side right -fill y -in .
	pack .output -side bottom -fill both -expand on -in .

	after idle .output yview moveto [lindex $window_current_position 1]
}

proc window.input_size {} {
	global window_input_size
	return $window_input_size
}

proc window.input_resize size {
	global window_input_size window_input_size_display


	if { $size == $window_input_size } {
		return 0
	}   
	.input configure -height $size 
	set window_input_size $size
	set window_input_size_display $size
	client.set_bindings
	return 0
}

proc window.dabbrev_search {win pattern} {
	set enough_words 10

	set from [$win index end]
	set psn $from
	set enough_lines [expr $from - 1000.0]
	set len 0

	while { 
		[set psn [$win search -backwards -nocase -- $pattern $from 1.0]] != {}
			&& $len < $enough_words
			&& $psn > $enough_lines
		} {


		set pre [$win get "$psn wordstart" $psn]
		regsub -all {[^A-Za-z]*} $pre {} pre
		if { $pre == {} } {
			set word [$win get $psn "$psn + 1 chars wordend"]
			regsub -all {[^A-Za-z]*$} $word {} word
			regsub -all {^[^A-Za-z]*} $word {} word
			if { $word != "" } {
				set word [string tolower $word]
					set words_db($word) 1
				set len [llength [array names words_db]]
			}
		}
		set from $psn
	}

	return [array names words_db]
}

proc window.dabbrev args {
	window.dabbrev_init
	set input [.input get 1.0 {end -1 char}]
	set partial_psn [string wordstart $input [string length $input]]
	set partial [string range $input $partial_psn end]
	if { $partial == "" } { 
		return
	}

	regsub -all {\?} $partial {\\?} new_partial
	regsub -all {\*} $new_partial {\\*} new_partial
	regsub -all {\+} $new_partial {\\+} new_partial
	regsub -all {\(} $new_partial {\\(} new_partial
	regsub -all {\)} $new_partial {\\)} new_partial
	regsub -all {\.} $new_partial {\\.} new_partial
	regsub -all {\[} $new_partial {\\[} new_partial


	set ttl 10
	set ttl 20

	regsub -all { } $new_partial {} new_partial



	if { $new_partial == "" } { 
		window.set_dabbrev_target ""
		window.set_dabbrev_matches ""
		window.set_dabbrev_current ""
		return
	}

	if { ([window.get_dabbrev_target] != "") &&
	 [string match -nocase "[window.get_dabbrev_target]*" $new_partial] } {


	 	set l [window.get_dabbrev_matches]

		if { [lsearch -exact $args backward] != -1 } {
			set last [lrange $l end end]
			set l [lreplace $l end end]
			set l [concat $last $l]
	 	} else {
			set first [lindex $l 0]
			set l [lreplace $l 0 0]
			lappend l $first
		}
		window.set_dabbrev_matches $l
		window.set_dabbrev_current [lindex $l 0]
	} {

		set words [window.dabbrev_search .output $new_partial]

		if { [llength $words] == 0 } {
			return
		}
		set words [lsort $words]
		if { [lindex $words 0] == [string tolower $new_partial] } {
			set foo [lindex $words 0]
			lappend words $foo
			set words [lreplace $words 0 0]
		}
		window.set_dabbrev_target $new_partial
		window.set_dabbrev_matches $words
		window.set_dabbrev_current [lindex $words 0]
	}

	set remainder [string range [window.get_dabbrev_current] [string length [window.get_dabbrev_target]] end]

	.input delete "end - [string length $partial] char - 1 char" end

	.input insert end "[window.get_dabbrev_target]$remainder"
}

proc window.dabbrev_init {} {
	global dabbrev_db
	if { ![info exists dabbrev_db(initialised)] } {
		set dabbrev_db(initialised) 1
		window.set_dabbrev_target ""
		window.set_dabbrev_matches ""
		window.set_dabbrev_current ""
	}
}

proc window.set_dabbrev_target target {
	global dabbrev_db
	set dabbrev_db(target) $target
}
proc window.get_dabbrev_target {} {
	global dabbrev_db
	return $dabbrev_db(target)
}

proc window.set_dabbrev_matches matches {
	global dabbrev_db
	set dabbrev_db(matches) $matches
}
proc window.get_dabbrev_matches {} {
	global dabbrev_db
	return $dabbrev_db(matches)
}

proc window.set_dabbrev_current current {
	global dabbrev_db
	set dabbrev_db(current) $current
}
proc window.get_dabbrev_current {} {
	global dabbrev_db
	return $dabbrev_db(current)
}


proc window.selection_to_input {} {
	catch { .input insert insert [selection get] }
}

proc window.paste_selection {} {
	catch {
		set select [selection get]
		set length [string length $select]
			set select [string range $select 0 [expr $length -1]]
		incr length -1
		if { [string index $select $length] == "\n" } {
			set select [string range $select 0 [expr $length -1]]
		}
		io.outgoing "@paste\n$select\n."
	}
}

proc window.clear_screen win {
	global window_db
	set window_db(".output,window_CR") 0
	$win configure -state normal
	$win delete 1.0 end
	$win configure -state disabled
}

proc window._last_char_is_visible {} {
	set last_char [.output index {end - 1 char}]
	if { [.output bbox $last_char] != {} } {
		return 1
	}
	return 0
}

set window_contributed_tags ""
proc window.contribute_tags tags {
	global window_contributed_tags
	set wct_list $window_contributed_tags
	foreach tag $tags {
		if { [lsearch -exact $wct_list $tag] == -1 } {
			append window_contributed_tags " $tag"
		}
	}
	set window_contributed_tags [string trimleft $window_contributed_tags]
}

proc window.remove_matching_tags match {
	global window_contributed_tags
	set tmp ""
	set wct_list $window_contributed_tags
	foreach tag $wct_list {
		if { [string match $match $tag] == 0 } {
			append tmp " $tag"
		}
	}
	set window_contributed_tags [string trimleft $tmp]
}

proc window.display_tagged { line {tags {}} } {
	global window_db
	if { $window_db(".output,window_CR") } {
		window._display "\n"
	} 
	set window_db(".output,window_CR") 1
	window._display $line

	foreach tag $tags {
		set names [lindex $tag 0]
		set range [lindex $tag 1]
		set from "end - 1 lines linestart + [lindex $range 0] chars"
		set to   "end - 1 lines linestart + [lindex $range 1] chars + 1 chars"
		foreach t $names {
				.output tag add $t $from $to
		}
	}
}

proc window._clip {} {
	global window_clip_output_buffer window_clip_output_buffer_size
	if { $window_clip_output_buffer } {
		set int_last_line [lindex [split [.output index end] "."] 0]
		set diff $int_last_line
		incr diff -$window_clip_output_buffer_size
		if { $diff > 0 } {
			.output delete 1.0 $diff.0
		}
	}
}

proc window._display { line { tag ""} {win .output} } {
	if { $win == ".output" } {
		global window_contributed_tags
		set scroll [window._last_char_is_visible]

		.output configure -state normal
		.output insert end $line "window_margin $window_contributed_tags $tag"
		window._clip
		.output configure -state disabled

		if { $scroll } {
			.output yview -pickplace end
			window.activity_stop_flashing
		} {
			window.activity_begin_flashing
		}
	} {
		$win configure -state normal
		$win insert end $line "window_margin $tag"
		$win configure -state disabled
	}
}

proc window.display {{ line "" } { tag "" } {win .output}} {
	global window_db
	if { $window_db("$win,window_CR") } {
		window._display "\n" $win
	}
	set window_db("$win,window_CR") 0
	window._display $line $tag $win
}

proc window.displayCR {{ line "" } { tag "" } {win .output}} {
	global window_db
	if { $window_db("$win,window_CR") } {
		window._display "\n" $win
	}
	set window_db("$win,window_CR") 1
	window._display $line $tag $win
}

proc window.hyperlink.init {} {
	global window_hyperlink_db
	set window_hyperlink_db(command) ""
	set window_hyperlink_db(x) -1
	set window_hyperlink_db(y) -1
}

proc window.hyperlink.escape_tcl str {
	regsub -all {\\} $str {\\\\} str
	regsub -all {\;} $str {\\;} str
	regsub -all {\[} $str {\\[} str
	regsub -all {\$} $str {\\$} str
	return $str
}
proc window.hyperlink.activate {} {
	global window_hyperlink_db
	if { $window_hyperlink_db(command) != "" } {
		set cmd [window.hyperlink.escape_tcl $window_hyperlink_db(command)]
		eval $cmd
	}
}

proc window.hyperlink.set_command cmd {
	global window_hyperlink_db
	set window_hyperlink_db(command) $cmd
}

proc window.hyperlink.click {x y} {
	global window_hyperlink_db
	set window_hyperlink_db(x) $x
	set window_hyperlink_db(y) $y
}   

proc window.hyperlink.motion {win tag x y} {
	global window_hyperlink_db
	set colour_unselected #0000ee
	set hyperlink_foreground [worlds.get_generic $colour_unselected {} {} HyperlinkForeground]
	set delta 2 
	if { ([expr abs($window_hyperlink_db(x) - $x)] > $delta) || 
		 ([expr abs($window_hyperlink_db(y) - $y)] > $delta) } {
		$win configure -cursor {}
		$win tag configure $tag -foreground $hyperlink_foreground
		window.hyperlink.set_command ""
	}
}

proc window.hyperlink.link {win tag cmd} {

	set cmd [window.hyperlink.escape_tcl $cmd]
	set colour_selected #ff0000
	set colour_unselected #0000ee

	set underline_hyperlink [worlds.get_generic hover {} {} UnderlineHyperlinks]
	set hyperlink_foreground [worlds.get_generic $colour_unselected {} {} HyperlinkForeground]

	if { $underline_hyperlink == "always" } {
		$win tag configure $tag -underline 1
	}

	$win tag configure $tag -foreground $hyperlink_foreground

	regsub -all {%} $cmd {%%} cmd  

	$win tag bind $tag <Enter> "
		$win configure -cursor hand2
		if { [lsearch -exact {hover always} $underline_hyperlink] != -1 } {
			$win tag configure $tag -underline 1
		}
		window.hyperlink.set_command \"$cmd\"
	"
	$win tag bind $tag <Leave> "
		$win configure -cursor {}
		if { [lsearch -exact {hover never} $underline_hyperlink] != -1 } {
			$win tag configure $tag -underline 0
		}
		window.hyperlink.set_command \"\"
	"
	$win tag bind $tag <1> "
		$win configure -cursor hand2
		$win tag configure $tag -foreground $colour_selected
		window.hyperlink.click %X %Y
		window.hyperlink.set_command \"$cmd\"
	"
	$win tag bind $tag <B1-Motion> "
		window.hyperlink.motion $win $tag %X %Y
	"
	$win tag bind $tag <B1-ButtonRelease> "
		$win tag configure $tag -foreground $hyperlink_foreground
		window.hyperlink.activate
	"

	$win tag lower $tag sel

	return $tag
}   
#
#


