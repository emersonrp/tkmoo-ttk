
window.menu_preferences_add "Edit Preferences..." preferences.edit
window.menu_preferences_state "Edit Preferences..." disabled

proc preferences.set_world world {
	global preferences_current preferences_category

	# preferences.copy_middle_to_world
	# preferences.remove_middle
	# preferences.fill_middle $world $preferences_category

	set preferences_current $world
}

proc preferences.set_category category {
	global preferences_current preferences_category 
	# preferences.copy_middle_to_world
	# .preferences.notebook.m configure -text "$category"
	# preferences.remove_middle
	# preferences.fill_middle $preferences_current $category
	set preferences_category $category
}

proc preferences.save {} {
	preferences.copy_middle_to_world
	global tkmooVersion
	catch { wm title . "[worlds.get [worlds.get_current] Name] - tkMOO-SE v$tkmooVersion" }
	catch { wm iconname . [worlds.get [worlds.get_current] Name] }

	preferences.clean_up
	destroy .preferences
	open.fill_listbox
	window.post_connect
}

proc preferences.copy_middle_to_world {} {
	global preferences_current preferences_v preferences_data

	foreach name [array names preferences_data] {
		foreach info $preferences_data($name) {
			set dtype([lindex [util.assoc $info directive] 1]) [lindex [util.assoc $info type] 1]
		}
	}

	set keys [array names preferences_v]

	foreach key $keys {

		foreach {world directive} [split $key ","] {break}

		set type ""
		catch { set type $dtype($directive) }

		if { $type == "" } {
			puts "preferences: c2m can't find a type for $directive!"
		}

		set v $preferences_v($key)

		if { $type == "boolean" } {
			if { $v == 1 } { 
				set v On
			} {
				set v Off
			}
		}

		worlds.set $world $directive $v
	}
}

proc preferences.remove_middle {} {
	global preferences_middle_windows
	eval destroy [pack slaves .preferences.middle]
	catch {eval destroy $preferences_middle_windows}
	.preferences.middle configure -state normal
	.preferences.middle delete 1.0 end
	.preferences.middle configure -state disabled
}

proc preferences.destroy {} {
	global preferences_v
	catch { destroy .preferences }
	catch { unset preferences_v }
}

proc preferences.clean_up {} {
	global preferences_v preferences_current
	catch { unset preferences_v }
	catch { unset preferences_current }
}

proc preferences.set_title title {
	set pw .preferences
	wm title $pw $title
}

proc preferences.create_edit_window {} {
	global tkmooVersion
	set pw .preferences
	catch {destroy $pw}

	toplevel $pw
	window.configure_for_macintosh $pw

	global tcl_platform
	if { $tcl_platform(platform) != "macintosh" } {
		bind $pw <Escape> "preferences.clean_up; destroy $pw"
	}

	window.place_nice $pw

	$pw configure -bd 0

	preferences.set_title "tkMOO-SE v$tkmooVersion: Preferences"

	set notebook $pw.notebook

	pack [ttk::notebook $notebook] -side top -fill both -expand 1
	ttk::notebook::enableTraversal $notebook

	set bottom $pw.bottom
	pack [ttk::frame $bottom] -side bottom

	ttk::button $bottom.save -text "Save" -command preferences.save
	ttk::button $bottom.reset -text "Reset" \
		-command {preferences.remove_middle; preferences.fill_middle $preferences_current $preferences_category}
	ttk::button $bottom.cancel -text "Cancel" \
		-command {preferences.clean_up; destroy .preferences}


	pack $bottom.save $bottom.reset $bottom.cancel -side left -padx 5 -pady 5

	window.focus $pw
}

proc preferences.edit { {world ""} } {
	global preferences_data preferences_current preferences_category

	set pw .preferences

	if { [winfo exists $pw] == 0 } {
		preferences.create_edit_window
	}

	preferences.clean_up

	worlds.load

	if { $world == "" } {
		set current [worlds.get_current]
		if { $current != "" } {
			set preferences_current $current
		} {

			set new [worlds.create_new_world]

			set session [db.get .output session]
			set host [db.get $session host]
			set port [db.get $session port]

			worlds.set $new Name "$host:$port"
			worlds.set $new Host $host
			worlds.set $new Port $port
			worlds.set $new ShortList On

			open.fill_listbox
			window.post_connect
			set new [lindex [worlds.worlds] end]

			set preferences_current $new

			worlds.set_current $new

			set session [db.get .output session]
			db.set $session world $new
		}
	} {
		set preferences_current $world
	}


	set notebook $pw.notebook
	set cat [lindex [preferences.cp] 0]

	foreach c [preferences.reverse $cat] {
		incr c_counter
		set page $notebook.$c_counter
		ttk::frame $page
		$notebook add $page -text $c
		ttk::scrollbar $page.scrollbar -command "$page yview"
		pack $page.scrollbar -side right -fill y
		preferences.populate_frame $preferences_current $c $page
	}
	# set preferences_category {General Settings}

	# preferences.remove_middle
	# preferences.fill_middle $preferences_current $preferences_category

	preferences.set_title "Preferences: [worlds.get $preferences_current Name]"

	wm deiconify $pw 
	after idle raise $pw
}

proc preferences.reverse list {
	if { $list == {} } {
		return {}
	} {
		return [concat [preferences.reverse [lrange $list 1 end]] [list [lindex $list 0]] ]
	}
}

proc preferences.change_action {world change_action parameter} {
	if { $change_action == {} } { return }
	if { $world == [worlds.get_current] } {
		eval [lindex $change_action 1] $parameter
	}
}

proc preferences.verify_updown_integer {str default low hi} {
	set value $default

	set str [string trim $str]

	if { ($str != "") && ([llength $str] == 1) } {


		regsub -all {^0} $str {} str

		if { $str == "" } {
			set str 0
		}

		if { [regexp {^[-]*[0-9]+$} $str num] == 1 } {
			set value $num
		}
	}
	if { $value < $low } { set value $low }
	if { $value > $hi }  { set value $hi }
	return $value
}

proc preferences.populate_frame {world category page} {
	global preferences_data preferences_v preferences_middle_windows

	global image_data
	image create bitmap up   -data $image_data(right.xbm)
	image create bitmap down -data $image_data(left.xbm)

	set cp [preferences.cp]
	set categories [lindex $cp 0]
	set providors [lindex $cp 1]

	# set preferences_middle_windows {}

	# set CR ""

	foreach providor $providors {

		if { [info exists preferences_data($providor,$category)] == 0 } {
			continue
		}

		set info $preferences_data($providor,$category)

		foreach preference $info {

			set f $page.[util.unique_id pf]
			pack [ ttk::frame $f ] -anchor w
			# lappend preferences_middle_windows $f

			# $middle configure -state normal
			# $middle insert end $CR
			# $middle window create end -window $f
			# set CR "\n"
			# $middle configure -state disabled

			foreach {_ directive} [util.assoc $preference directive] {_ type} [util.assoc $preference type] {break}

			foreach default [worlds.get_default $directive] {break}
			foreach {_ display} [util.assoc $preference display] {break}


			label $f.l -text $display -anchor w -width 20 -justify left
			pack $f.l -side left

			switch -- $type {
				boolean {
					ttk::checkbutton $f.b \
						-variable preferences_v($world,$directive)
					set v $default
					catch { set v [worlds.get $world $directive] }
					if { [string tolower $v] == "on" } { 
						set v 1
					} {
						set v 0
					}
					set preferences_v($world,$directive) $v
					pack $f.b -side left
				}

				choice-radio {
					set choices [lindex [util.assoc $preference choices] 1]
					if { [util.assoc $preference e-choices] != {} } {
						set callback [lindex [util.assoc $preference e-choices] 1]
						set choices [$callback]
					}
					foreach choice [preferences.reverse $choices] {
						set b [util.unique_id choice]
						ttk::radiobutton $f.$b \
							-text $choice \
							-value $choice \
							-variable preferences_v($world,$directive)
						pack $f.$b -side left
					}
					set v $default
					catch { set v [worlds.get $world $directive] }
					set preferences_v($world,$directive) $v
				}
	
				updown-integer {
	
					set low [lindex [util.assoc $preference low] 1]
					set high [lindex [util.assoc $preference high] 1]
	
					set delta 1
					if { [set ldelta [util.assoc $preference delta]] != {} } {
						set delta [lindex $ldelta 1]
					}
	
	
					ttk::entry $f.e -font [fonts.get fixedwidth] -width 5
					pack $f.e -side left
					bind $f.e <Return> "
						set x \[$f.e get\]
						set a \[preferences.verify_updown_integer \$x $default $low $high\]
						$f.e delete 0 end
						$f.e insert insert \$a
						set preferences_v($world,$directive) \$a
					"
					bind $f.e <Leave> [bind $f.e <Return>]
					bind $f.e <Tab> [bind $f.e <Return>]
	
					ttk::frame $f.gap -width 2
	
					ttk::button $f.bdown -text "-" -image down \
							-width 10 \
							-command "
						set a \[preferences.verify_updown_integer \[$f.e get\] $default $low $high\]
						incr a -$delta
						set a \[preferences.verify_updown_integer \$a $default $low $high\]
						$f.e delete 0 end
						$f.e insert insert \$a
						set preferences_v($world,$directive) \$a
					"
					ttk::button $f.bup -text "+" -image up \
							-width 10 \
							-command "
						set a \[preferences.verify_updown_integer \[$f.e get\] $default $low $high\]
						incr a $delta
						set a \[preferences.verify_updown_integer \$a $default $low $high\]
						$f.e delete 0 end
						$f.e insert insert \$a
						set preferences_v($world,$directive) \$a
					"
	
					pack $f.gap -side left -fill y
					pack $f.bdown -side left -fill y
					pack $f.bup -side left -fill y
	
					set v $default
					catch { set v [worlds.get $world $directive] }
					set preferences_v($world,$directive) $v
					$f.e delete 0 end
					$f.e insert insert $v
	
				}
	
				choice-menu {
					ttk::menubutton $f.mb -menu $f.mb.m
					pack $f.mb -side left
					menu $f.mb.m -tearoff 0
					set choices [lindex [util.assoc $preference choices] 1]
					if { [util.assoc $preference e-choices] != {} } {
						set callback [lindex [util.assoc $preference e-choices] 1]
						set choices [$callback]
					}
					foreach choice $choices {
						$f.mb.m add command -label $choice \
								-command "set preferences_v($world,$directive) $choice; $f.mb configure -text $choice"
						window.hidemargin $f.mb.m
					}
					set v $default
					catch { set v [worlds.get $world $directive] }
					set preferences_v($world,$directive) $v
					$f.mb configure -text $v
				}
	
				string {
					ttk::entry $f.e -font [fonts.get fixedwidth] -width 30
					bind $f.e <KeyRelease> "set preferences_v($world,$directive) \[$f.e get\]"
					bind $f.e <Leave> "set preferences_v($world,$directive) \[$f.e get\]"
					set v $default
					catch { set v [worlds.get $world $directive] }
					set preferences_v($world,$directive) $v
					$f.e insert insert $v
					pack $f.e -side left
	
					if { $world == [worlds.default_world] && ($directive == "Name") } {
						$f.e delete 0 end 
						$f.e insert insert "DEFAULT WORLD"
						$f.e configure -state disabled -cursor {}
					}
				}
	
				font {
					ttk::entry $f.e -font [fonts.get fixedwidth] 
					ttk::frame $f.gap -width 2
					set v $default
					catch { set v [worlds.get $world $directive] }
					set preferences_v($world,$directive) $v
					ttk::button $f.b -text "Choose" \
							-command "fontchooser.create \
						\"preferences.set_font $f.e $world $directive\" \
						\"\[$f.e get\]\"
					"
					bind $f.e <KeyRelease> "set preferences_v($world,$directive) \[$f.e get\]"
					bind $f.e <Leave> "set preferences_v($world,$directive) \[$f.e get\]"
					$f.e insert insert $v
					pack $f.e -side left -fill x -expand 1
					pack $f.gap -side left -fill y
					pack $f.b -side right -fill y 
				}
	
				file {
					ttk::entry $f.e -font [fonts.get fixedwidth]
					ttk::frame $f.gap -width 2
					set v $default
					catch { set v [worlds.get $world $directive] }
					set preferences_v($world,$directive) $v
					set filetypes [lindex [util.assoc $preference filetypes] 1]
					set filetypes [list $filetypes]
					set file_access [util.assoc $preference file-access]
					set get_proc tk_getSaveFile
					if { ($file_access != {}) &&
				 	([string tolower [lindex $file_access 1]] == "readonly") } {
						set get_proc tk_getOpenFile
					}
					global tcl_platform
					ttk::button $f.b -text "Choose" \
						-command "
							set file \[$f.e get\]
							if { \$tcl_platform(platform) == \"macintosh\" && 
							 	! \[file exists \$file\] } {
								set filename \[$get_proc -filetypes $filetypes \
									-parent .preferences \
									-title \"$display\" \
									\]
							} {
								set filename \[$get_proc -filetypes $filetypes \
									-initialdir \[file dirname \$file\] \
									-initialfile \[file tail \$file\] \
									-parent .preferences \
									-title \"$display\" \
									\]
							}
							if { \$filename != \"\" } {
								set preferences_v($world,$directive) \$filename
								$f.e delete 0 end
								$f.e insert insert \$filename
							}
						"
					bind $f.e <KeyRelease> "set preferences_v($world,$directive) \[$f.e get\]"
					bind $f.e <Leave> "set preferences_v($world,$directive) \[$f.e get\]"   
					$f.e insert insert $v
					pack $f.e -side left -fill x -expand 1
					pack $f.gap -side left -fill y 
					pack $f.b -side right -fill y
				}
	
				colour {
					ttk::entry $f.c -font [fonts.get fixedwidth] \
							-cursor {} \
					-state disabled
					ttk::frame $f.gap -width 2
					ttk::button $f.b -text "Choose" \
								-command "colourchooser.create \
												\"preferences.set_colour $f $world $directive\" \
												\$preferences_v($world,$directive)"
	
					set v $default
					catch { set v [worlds.get $world $directive] }
					catch { set v $preferences_v($world,$directive) }
					set preferences_v($world,$directive) $v
					$f.c configure -background $v
					bind $f.c <1> "colourchooser.create \"preferences.set_colour $f $world $directive\" \$preferences_v($world,$directive)"
					pack $f.c -side left
					pack $f.gap -side left -fill y
					pack $f.b -side right -fill y 
				}
	
				password {
					ttk::entry $f.e \
						-show "*" \
						-font [fonts.get fixedwidth] -width 30
					bind $f.e <KeyRelease> "set preferences_v($world,$directive) \[$f.e get\]"
					bind $f.e <Leave> "set preferences_v($world,$directive) \[$f.e get\]"
					set v $default
					catch { set v [worlds.get $world $directive] }
					set preferences_v($world,$directive) $v
					$f.e insert insert $v
					pack $f.e -side left
				}
	
				text {
					$f.l configure -anchor nw
					text $f.t -font [fonts.get fixedwidth] \
						-borderwidth 1 \
						-relief sunken \
						-width 30 -height 2
					global tcl_platform
					if { $tcl_platform(platform) == "macintosh" } {
						$f.t configure -highlightbackground #cccccc
					}
					bind $f.t <KeyRelease> "set preferences_v($world,$directive) \[preferences.text_list_to_str \[preferences.get_text $f.t\]\]"
					bind $f.t <Leave> "set preferences_v($world,$directive) \[preferences.text_list_to_str \[preferences.get_text $f.t\]\]"
					set v $default
					catch { set v [worlds.get $world $directive] }
					set preferences_v($world,$directive) $v
					$f.t insert insert $v
					pack $f.t -side left
				}
	
				default {
					puts "preferences, unable to handle type $type"
				}
			}
		}
	}
}

proc preferences.get_text win {
	set lines {}
	set last [$win index end]
	for {set n 1} {$n < $last} {incr n} {
		set line [$win get "$n.0" "$n.0 lineend"]
		lappend lines $line
	}
	return $lines
}

proc preferences.text_list_to_str list {
	return [join $list "\n"]
}

proc preferences.set_font {args} {
	global preferences_v
	catch {
	set e [lindex $args 0]
	set world [lindex $args 1]
	set directive [lindex $args 2]
	$e delete 0 end
	$e insert insert [lrange $args 3 end]
	set preferences_v($world,$directive) [$e get]
	}
}


proc preferences.set_colour { f world directive r g b } {
	global preferences_v
	catch {
		set hex #[to_hex $r][to_hex $g][to_hex $b]
		$f.c configure -background $hex
		set preferences_v($world,$directive) $hex
	}
}

proc preferences.register { providor category info } {
	global preferences_data
	if { [info exists preferences_data($providor,$category)] == 1 } {
		set preferences_data($providor,$category) [concat $preferences_data($providor,$category) $info]
	} {
		set preferences_data($providor,$category) $info
	}
}

proc preferences.get_directive directive {
	global preferences_data
	set ld [string tolower $directive]
	foreach pc [array names preferences_data] {
		foreach record $preferences_data($pc) {
			if { [string tolower [lindex [util.assoc $record directive] 1]] == $ld } {
				return $record
			}
		}
	}
	return {}
}

proc preferences.cp {} {
	global preferences_data
	set keys [array names preferences_data]
	set categories {}
	set providors {}
	foreach key $keys {
		set pc [split $key ","]
		set p [lindex $pc 0]
		set c [lindex $pc 1]
		if { [lsearch -exact $providors $p] == -1 } {
			lappend providors $p
		}
		if { [lsearch -exact $categories $c] == -1 } {
			lappend categories "$c"
		}
	}
	return [list $categories $providors]
}


#puts "preferences.tcl contains font browser hooks..."
preferences.register window {General Settings} {
	{ {directive Name}
		{type string}
		{default ""}
		{display World} }
	{ {directive Host}
		{type string}
		{default ""}
		{display Host} }
	{ {directive Port}
		{type string}
		{default ""}
		{display Port} }
	{ {directive Login}
		{type string}
		{default ""}
		{display "User name"} }
	{ {directive Password}
		{type password}
		{default ""}
		{display "Password"} }
	{ {directive ShortList}
		{type boolean}
		{default off}
		{display "On short list"} }
	{ {directive LocalEcho}
		{type boolean}
		{default on}
		{change_action client.set_echo}
		{display "Local echo"} }
	{ {directive InputSize}
		{type choice-menu}
		{default 1}
		{display "Input window size"}
		{change_action window.input_resize}
		{choices {1 2 3 4 5}} }
	{ {directive WindowResize}
		{type boolean}
		{default off}
		{display "Always resize window"} }
	{ {directive ClientMode}
		{type choice-menu}
		{default line}
		{display "Client mode"}
		{change_action client.set_mode}
		{choices {character line}} }
	{ {directive UseModuleLogging}
		{type boolean}
		{default off}
		{display "Write to log file"} }
	{ {directive LogFile}
		{type file}  
		{filetypes {
			{{Log Files} {.log} TEXT} 
			{{Text Files} {.txt} TEXT}
			{{All Files} {*} TEXT}
		} }
		{default ""}
		{display "Log file name"} }
	{ {directive ConnectScript}
		{type text}
		{default "connect %u %p"}
		{display "Connection script"} }
	{ {directive DisconnectScript}
		{type text}
		{default {}}
		{display "Disconnection script"} }
}

if { $tcl_platform(platform) == "macintosh" } {
	set default_binding "macintosh"
} {
	set default_binding "windows"
}

preferences.register window {General Settings} [list	\
	[list {directive KeyBindings}	\
		{type choice-menu}		\
		"default $default_binding"	\
		{display "Key bindings"}	\
		{change_action bindings.set}	\
		{choices {emacs tf windows macintosh default}} ] \
]

preferences.register window {Colours and Fonts} [list \
	{ {directive ColourForeground} \
		{type colour} \
		{default "#fefefe"} \
		{default_if_empty} \
		{display "Normal text colour"} } \
	{ {directive ColourBackground} \
		{type colour} \
		{default "#000000"} \
		{default_if_empty} \
		{display "Background colour"} } \
	{ {directive ColourLocalEcho} \
		{type colour} \
		{default "#bbbbbb"} \
		{default_if_empty} \
		{display "Local echo colour"} } \
	{ {directive ColourForegroundInput} \
		{type colour} \
		{default "#000000"} \
		{default_if_empty} \
		{display "Input text"} } \
	[list {directive ColourBackgroundInput} \
		{type colour} \
		[list default [colourdb.get pink]] \
		{default_if_empty} \
		{display "Input background"} ] \
	{ {directive DefaultFont} \
		{type choice-menu} \
		{default fixedwidth} \
		{display "Default font type"} \
		{change_action preferences.x_reconfigure_fonts} \
		{choices {fixedwidth proportional}} } \
	{ {directive FontFixedwidth} \
		{type font} \
		{default ""} \
		{default_if_empty} \
		{display "Fixedwidth font"} } \
	{ {directive FontPlain} \
		{type font} \
		{default ""} \
		{default_if_empty} \
		{display "Proportional font"} } \
	{ {directive FontBold} \
		{type font} \
		{default ""} \
		{default_if_empty} \
		{display "Bold font"} } \
	{ {directive FontItalic} \
		{type font} \
		{default ""} \
		{default_if_empty} \
		{display "Italic font"} } \
	{ {directive FontHeader} \
		{type font} \
		{default ""} \
		{default_if_empty} \
		{display "Header font"} } \
] 

preferences.register client {Out of Band} {

	{ {directive UseModuleXMCP11}
		{type boolean}
		{default on}
		{display "XMCP/1.1 enabled"} }
	{ {directive XMCP11_AfterAuth}
		{type text}
		{default {}}
		{display "XMCP/1.1 connection\nscript"} }
}

preferences.register client {Special Forces} {
	{ {directive UseLoginDialog}
		{type boolean}
		{default On}
		{display "Display login dialog"} }
	{ {directive ModulesDebug}
		{type boolean}
		{default Off}
		{display "Display plugin errors"} }
}

proc preferences.x_reconfigure_fonts font {
	global window_fonts
	set window_fonts $font
	client.reconfigure_fonts
}
#
#

