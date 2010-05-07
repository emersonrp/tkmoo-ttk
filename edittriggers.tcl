
client.register edittriggers start
client.register edittriggers client_connected
client.register edittriggers incoming
client.register edittriggers outgoing

window.menu_tools_add "Edit Triggers" edittriggers.edit
window.menu_tools_macintosh_accelerator "Edit Triggers" "Cmd+T"



set edittriggers_default_triggers {## An example triggers.tkm file.  Comment lines begin with the '#'
## character.  This file can contain valid TCL commands and procedure
## definitions.  Three special procedures are predefined:
## 
##	trigger
##		when a line arrives from the server and matches
##		this regular expression execute this command
##
##	macro
##		when the user types a line matching this regular
##		expression execute this command
##
##	gag
##		when a line arrives from the server and matches
##		this regular expression supress the line, displaying
##		nothing on the main client window.
##
## You can find out more about Triggers, Gags and Macros at
## tkMOO-light's supporting website:
## 
##     http://www.awns.com/tkMOO-light/

## ---------------------------------------------------------------------
## MOOs send a '*** Connected ***' string when you connect.  Hide this
## message.

## Remove the single comment character '#' from the next line for
## this gag to take effect.

 gag -regexp {^\*+ .* \*+$}
## ---------------------------------------------------------------------

## ---------------------------------------------------------------------
## Do you ever get annoyed because you have to type a '"' character
## before everything you want to say?  This complicated looking macro
## will test what you type to see if it starts with a special character
## or if the first word is a known command.  Anything that isn't
## recognised is assumed to be something you want to say.

# macro -regexp {^(.)([^ ]*)(.*)$}  #    -command {
#        set special {think walk play poke look help examine news
#                     l i n s e w ne se nw sw u d ping throw idle get
#		     read
#                     drop put take join home}
#        if { ([lsearch -exact {\" \: \@ \` \; \' \! \| \.} $m1] == -1) && 
#             ([lsearch -exact $special $m1$m2] == -1) } {
#            io.outgoing "\"$m1$m2$m3"
#        } {
#            io.outgoing "$m1$m2$m3"
#        }
#    }
## ---------------------------------------------------------------------

## ---------------------------------------------------------------------
## Pay special attention to your friends, Janet and John.  If they
## say anything then display their names in Blue letters.

# tag configure Blue -foreground [colour.get blue]
# trigger -regexp {^(kipper|epitaph|denbro|figulesquidge|brother|joe|\[chris\]|R4) (.*)}  #         -continue  #         -command {
#             bell
#         }
## ---------------------------------------------------------------------

## ---------------------------------------------------------------------
## You can close the client window and use this trigger to alert you
## when someone starts talking.  This trigger rings the bell and
## makes the client window pop open.

# trigger -continue  #         -command {
#             bell
#             window.deiconify
#         }
## ---------------------------------------------------------------------

## ---------------------------------------------------------------------
## MOO Login Watchers display arrivals and departures with messages
## like the following:
## 	< Name has disconnected. ... >
## Display these notification messages in the client's status bar
## instead of displaying in the client's main window.

 trigger -regexp {^\<\=\= connected: (.*), Total: (.*) \=\=\>$}  -command { 
             window.set_status "$m1 has connected."
                      }
 trigger -regexp {^\<\=\= disconnected: (.*), Total: (.*) \=\=\>$}  -command { 
             window.set_status "$m1 has disconnected." 
         }
trigger -regexp {^\<\=\= client disconnected: (.*), Total: (.*) \=\=\>$}  -command { 
             window.set_status "$m1 has disconnected." 
         }

## ---------------------------------------------------------------------
## Page Windows and Channel Windows are below

#trigger -regexp {^([^ ]*) pages, "(.*)"$}  -command {
#           subwindow.display $m1 $m2
#        }

 trigger -regexp {^\[([\+\-])\]\[([^]]*)\] (.*)$}  -command {
             chanwin.display "\[$m1\]\[$m2\]" "=$m2:" $m3
         }

macro -regexp {^FROM_SUBWINDOW (\[([\+\-])\]\[([^]]*)\]) (.*)$}  -command {
          io.outgoing "=\"$m3\" $m4"
      }

macro -regexp {^FROM_SUBWINDOWN (\[([\+\-])\]\[([^]]*)\]) (.*)$}  -command {
          io.outgoing "=\"$m3\":$m4"
      }

#macro -regexp {^FROM_SUBWINDOW ([^ ]*)(.*)$}  -command {
#          io.outgoing "page $m1 $m2"
#          subwindow.display "$m1" ">>> $m2"
#      }
## ---------------------------------------------------------------------
## When you get beeped, or have new mail a popup will tell you

trigger -regexp {^(.*) has beeped you to get your attention.$}  -command {dialog "$m1 has beeped you"}

trigger -regexp {^You have new mail (.*) from (.*).$}  -command {dialog "New Mail from $m2"}
## ---------------------------------------------------------------------
## If you have a compass then this trigger will move you automaticly

trigger -regexp {^The arrow on .* points (to '(.*)'\.|to the (.*)\.|(.*))} -command {
            after 2000
            catch {io.outgoing $m2}
            catch {io.outgoing $m3}
            catch {io.outgoing $m4}
}
#trigger -regexp {^The arrow on (.*) points to the (.*).$}  -command {
#            after 2000 
#            io.outgoing "go $m2"
#      }
#trigger -regexp {^The arrow on (.*) points ([^ ]*)}  -command {
#            after 2000 
#            io.outgoing "go $m2"
#      }
## ---------------------------------------------------------------------}
proc edittriggers.default_triggers {} {
    global edittriggers_default_triggers
    return [split $edittriggers_default_triggers "\n"]
}

proc edittriggers.create_default_file {} {
    set file [edittriggers.file]
    if { $file != "" } {
        return
    }

    set file [edittriggers.preferred_file]

    set fd ""
    catch { set fd [open $file "w+"] }
    if { $fd == "" } {
        window.displayCR "Can't write to file $file" window_highlight
        return
    }
    
    foreach line [edittriggers.default_triggers] {
        puts $fd $line
    }
    close $fd
}           

proc edittriggers.start {} {
    global edittriggers_slave edittriggers_use edittriggers_registered_aliases
    global edittriggers_contributed
    global edittriggers_initialised

    edittriggers.create_default_file

    set edittriggers_initialised 0

    array set edittriggers_contributed {
	trigger	{}
	macro	{}
	gag	{}
    }

    set edittriggers_use 1

    global edittriggers_hyperlink_command
    set edittriggers_hyperlink_command ""

    .output tag configure FontPlain  -font [fonts.plain]
    .output tag configure FontItalic -font [fonts.italic]

    set edittriggers_registered_aliases {}

}

proc edittriggers.client_connected {} {
    global edittriggers_use edittriggers_slave
    set default_usage 1
    set edittriggers_use $default_usage
    set use ""
    catch {
      set use [string tolower [worlds.get [worlds.get_current] UseModuleTriggers
]]  
    } 
    if { $use == "on" } {
        set edittriggers_use 1
    } elseif { $use == "off" } {
        set edittriggers_use 0
    }   
    ###

    edittriggers.init_slave

    return [modules.module_deferred]
}

#proc edittriggers.escape_tcl str {
#}

#}

proc edittriggers.make_hyperlink {tag command} {
    window.hyperlink.link .output T_$tag $command
}

#proc edittriggers.set_click_coords {x y} {
#}

#proc edittriggers.hyperlink_motion {tag x y} {
#}

#proc edittriggers.set_goto_command command {
#}   

#proc edittriggers.tag_hyperlink_Button1-ButtonRelease {} {
#}

proc edittriggers.incoming_line {} {
    global edittriggers_incoming_line
    return $edittriggers_incoming_line
}

proc edittriggers.set_incoming_line line {
    global edittriggers_incoming_line
    set edittriggers_incoming_line $line
}

proc edittriggers.incoming event {
    global edittriggers_slave edittriggers_incoming_line edittriggers_use

    if { $edittriggers_use == 0 } {
        return
    }

    global edittriggers_initialised
    if { $edittriggers_initialised == 0 } {
	set edittriggers_initialised 1
        edittriggers.init_slave 
    }

    set line [db.get $event line]

    set edittriggers_incoming_line $line

    if { [catch { interp eval $edittriggers_slave incoming NULL } rv] } {
	window.displayCR "Triggers Error (incoming): $rv" window_highlight
	window.displayCR "It looks like there's a problem with one of the triggers you" window_highlight
	window.displayCR "have defined." window_highlight
	return
    } {
	#
	#
        #

	db.set $event line $edittriggers_incoming_line

#window.displayCR "edittriggers.incoming rv=$rv"

        return $rv
    }
}

proc edittriggers.outgoing_line {} {
    global edittriggers_outgoing_line
    return $edittriggers_outgoing_line
}

proc edittriggers.outgoing line {
    global edittriggers_slave edittriggers_use edittriggers_outgoing_line
    if { $edittriggers_use == 0 } {
        return
    }
    global edittriggers_initialised
    if { $edittriggers_initialised == 0 } {
        set edittriggers_initialised 1
        edittriggers.init_slave 
    }
    set edittriggers_outgoing_line $line
    if { [catch { interp eval $edittriggers_slave outgoing NULL } rv] } {
        window.displayCR "Triggers Error (outgoing): $rv" window_highlight
	window.displayCR "It looks like there's a problem with one of the macros you" window_highlight
	window.displayCR "have defined." window_highlight
        return
    } {
        return $rv
    }   
}



proc edittriggers.preferred_file {} {
    global tcl_platform env tkmooLibrary
    set file triggers.tkm

    set dirs {}
    switch $tcl_platform(platform) {
        macintosh { 
	    if { [info exists env(TKMOO_LIB_DIR)] } {
	        lappend dirs [file join $env(TKMOO_LIB_DIR)]
	    }
	    if { [info exists env(PREF_FOLDER)] } {
                lappend dirs [file join $env(PREF_FOLDER)]
	    }
            lappend dirs [file join $tkmooLibrary]       
        }
        windows { 
	    if { [info exists env(TKMOO_LIB_DIR)] } {
	        lappend dirs [file join $env(TKMOO_LIB_DIR)]
	    }
	    if { [info exists env(HOME)] } {
	        lappend dirs [file join $env(HOME) tkmoo]
	    }
            lappend dirs [file join $tkmooLibrary]       
        }
        unix -
        default { 
	    if { [info exists env(TKMOO_LIB_DIR)] } {
	        lappend dirs [file join $env(TKMOO_LIB_DIR)]
	    }
	    if { [info exists env(HOME)] } {
	        lappend dirs [file join $env(HOME) .tkMOO-lite]
	    }
            lappend dirs [file join $tkmooLibrary]       
        }
    }

    foreach dir $dirs {
        if { [file exists $dir] && 
	     [file isdirectory $dir] &&
	     [file writable $dir] } {
            return [file join $dir $file]
        }
    }

    return [file join [pwd] $file]
}

proc edittriggers.file {} { 
    global tkmooLibrary tcl_platform env
                

    set f triggers.tkm
    set files {}

    switch $tcl_platform(platform) {
        macintosh {
            lappend files [file join [pwd] $f]
            lappend files [edittriggers.preferred_file]
        }
        windows {
            lappend files [file join [pwd] $f]
            lappend files [edittriggers.preferred_file]
        }
        unix -
        default {
            lappend files [file join [pwd] $f]
            lappend files [edittriggers.preferred_file]
        }
    }
       
    foreach file $files {
        if { [file exists $file] } {
            return $file
        }
    }
    
    return ""
}   

proc edittriggers.edit {} {
    set triggers_file [edittriggers.file]

    if { $triggers_file != "" } {
	set filehandle ""
        catch { set filehandle [open $triggers_file "r"] }
	if { $filehandle == "" } {
	    window.displayCR "Can't read from file $triggers_file" window_highlight
	    return
	}
        set lines ""
        while { [gets $filehandle line] != -1 } {
            lappend lines $line
        }
        close $filehandle
    } {
	set lines ""
    }

    set save_file $triggers_file
    if { $save_file == "" } {
	set save_file [edittriggers.preferred_file]
    }
    set e [edit.SCedit "" $lines "" "$save_file" "Triggers"]
    edit.configure_send $e "Set" "edittriggers.save $e \"$save_file\"" 1
    edit.configure_send_and_close $e "Set and Close" "edittriggers.save_and_close $e \"$save_file\"" 9
}

proc edittriggers.save_and_close { e file } {
    edittriggers.save $e $file
    edit.destroy $e
}

proc edittriggers.save { e file } {
    global edittriggers_slave
    set filehandle ""
    catch { set filehandle [open $file "w"] }
    if { $filehandle == "" } {
	window.displayCR "Can't write to file $file" window_highlight
	return
    }
    set CR ""
    foreach line [edit.get_text $e] {
	puts -nonewline $filehandle "$CR$line"
	set CR "\n"
    }
    close $filehandle

    edittriggers.init_slave 
}

proc edittriggers.remove_existing_tags {} {
    set tags [.output tag names]
    foreach tag $tags {
	if { [string match "T_*" $tag] == 1 } {
	    .output tag delete $tag
	}
    }
}

proc edittriggers.init_slave {} {
    global edittriggers_slave edittriggers_api
    global edittriggers_contributed
    catch { interp delete $edittriggers_slave }
    set edittriggers_slave [edittriggers.create_slave]
    edittriggers.initapi_slave $edittriggers_slave
    interp eval $edittriggers_slave $edittriggers_api
    set triggers_file [edittriggers.file]
    if { $triggers_file != "" } {
	interp eval $edittriggers_slave source \"$triggers_file\"
    }
    foreach type {trigger macro gag} {
        foreach record $edittriggers_contributed($type) {
	    interp eval $edittriggers_slave $type $record
        }
    }
    interp eval $edittriggers_slave sort_data
}

###
proc edittriggers.create_slave {} {
    return [interp create]
}

proc edittriggers.initapi_slave slave {
    global edittriggers_registered_aliases


    $slave alias incoming_line			edittriggers.incoming_line
    $slave alias set_incoming_line		edittriggers.set_incoming_line
    $slave alias outgoing_line			edittriggers.outgoing_line

    $slave alias worlds.get_current		worlds.get_current
    $slave alias worlds.get			worlds.get
    $slave alias worlds.get_generic		worlds.get_generic

    $slave alias window.append_tagging_info	window.append_tagging_info
    $slave alias window.assert_tagging_info	window.assert_tagging_info

    $slave alias window.display			window.display
    $slave alias window.displayCR		window.displayCR
    $slave alias window.display_tagged		window.display_tagged
    $slave alias client.outgoing		client.outgoing
    $slave alias io.outgoing			io.outgoing
    $slave alias modules.module_deferred	modules.module_deferred
    $slave alias modules.module_ok		modules.module_ok
    $slave alias unique_id			util.unique_id
    $slave alias tag				edittriggers.tag

    $slave alias colour.get			colourdb.get
    $slave alias fonts.get			fonts.get

    $slave alias bell				bell
    $slave alias window.iconify			window.iconify
    $slave alias window.deiconify		window.deiconify
    $slave alias window.set_status		window.set_status
    $slave alias wm				wm

    $slave alias make_hyperlink			edittriggers.make_hyperlink
    $slave alias window.hyperlink.link		window.hyperlink.link

    foreach ra $edittriggers_registered_aliases {
        $slave alias [lindex $ra 0] [lindex $ra 1]
    } 
}

proc edittriggers.register_alias {alias real} {
    global edittriggers_registered_aliases
    if { [info exists edittriggers_registered_aliases] == 0 } {
	window.displayCR "Triggers Error:	edittriggers.register_alias called before edittriggers.start" window_highlight
	window.displayCR "		you need to call edittriggers.register_alias from inside" window_highlight
	window.displayCR "		a registered .start procedure"  window_highlight
	return 0;
    }
    if { [lsearch -exact $edittriggers_registered_aliases "$alias $real"] == -1
} {
        lappend edittriggers_registered_aliases "$alias $real"
        return 1
    }
    return 0
} 

proc edittriggers.tag { option name args } {
    set x [concat [list .output tag $option T_$name] $args]
    eval $x
    .output tag lower T_$name sel
}

proc edittriggers.trigger args {
    global edittriggers_contributed
    lappend edittriggers_contributed(trigger) $args
}
proc edittriggers.macro args {
    global edittriggers_contributed
    lappend edittriggers_contributed(macro) $args
}
proc edittriggers.gag args {
    global edittriggers_contributed
    lappend edittriggers_contributed(gag) $args
}

set edittriggers_api {

    set gag_data [list]
    set trigger_data [list]
    set macro_data [list]

    set gag_data_x [list]
    set trigger_data_x [list]
    set macro_data_x [list]

    proc sort_data {} {
        global gag_data trigger_data macro_data \
	       gag_data_x trigger_data_x macro_data_x

        set type default
        catch {set type [worlds.get [worlds.get_current] Type]}
        set world default
        catch {set world [worlds.get [worlds.get_current] Name]}
        catch {set world [worlds.get [worlds.get_current] World]}

        set candidates {}
        foreach rc $trigger_data_x {
            set n [lindex $rc 0]
            set t [lindex $rc 1]
            set d [lindex $rc 7]

            if { ($n != "") && ([regexp $n $world] == 0) } { continue }
            if { ($t != "") && ([regexp $t $type] == 0) } { continue }
            if { ($d != "") && 
		 ([string tolower [worlds.get_generic On {} {} $d]] == "off") } {
                 continue
            }

            lappend candidates $rc
        }
	set candidates [lsort -decreasing -command cmp_priority $candidates]
        set trigger_data $candidates

        set candidates {}
        foreach rc $gag_data_x {
            set n [lindex $rc 0]
            set t [lindex $rc 1]
            set d [lindex $rc 4]

            if { ($n != "") && ([regexp $n $world] == 0) } { continue }
            if { ($t != "") && ([regexp $t $type] == 0) } { continue }
            if { ($d != "") && 
		 ([string tolower [worlds.get_generic On {} {} $d]] == "off") } {
                 continue
            }

            lappend candidates $rc
        }
        set gag_data $candidates

        set candidates {}
        foreach rc $macro_data_x {
            set n [lindex $rc 0]
            set t [lindex $rc 1]
            set d [lindex $rc 7]

            if { ($n != "") && ([regexp $n $world] == 0) } { continue }
            if { ($t != "") && ([regexp $t $type] == 0) } { continue }
            if { ($d != "") && 
		 ([string tolower [worlds.get_generic On {} {} $d]] == "off") } {
                 continue
            }

            lappend candidates $rc
        }
	set candidates [lsort -decreasing -command cmp_priority_macro $candidates]
        set macro_data $candidates
    }

    proc incoming line {
	set line [incoming_line]
        if { [match_gags $line] == 1 } {
            return [modules.module_ok]
        } {
            return [match_triggers $line]
        }
    }

    proc outgoing line {
        set line [outgoing_line]
        return [match_macros $line] 
    }


    proc match_gags line {
        global gag_data
        foreach data $gag_data {
	    set r [lindex $data 2]
	    set nocase [lindex $data 3]
	    if { $nocase } {
		if { [regexp -nocase -- $r $line] } {
		    return 1
		}
	    } {
		if { [regexp -- $r $line] } {
		    return 1
		}
	    }
        }
        return 0
    }



    proc highlight {tag range} {
	global highlights
	lappend highlights [list $tag $range]
    }



    proc highlight_all { regexp line tag } {
	foreach record [_match_all $regexp $line $tag] {
	    highlight [lindex $record 0] [lindex $record 1]
	}
    }

    proc _correct_offset { list plus } {
        set tmp {}
        foreach raft $list {
	    set tags [lindex $raft 0]
	    set fr [lindex [lindex $raft 1] 0]
	    set to [lindex [lindex $raft 1] 1]
	    incr fr $plus
	    incr to $plus
	    set newraft [list $tags [list $fr $to]]
	    lappend tmp $newraft
        }
        return $tmp
    }

    proc _match_all { regexp line tag } {
	if { [regexp -indices -- ($regexp) $line p0 p1] == 1 } {
	    set before  [string range $line 0 [expr [lindex $p1 0] - 1]]
	    set rbefore [_match_all $regexp $before $tag]

	    set after  [string range $line [expr [lindex $p1 1] + 1] end]
	    set rafter [_match_all $regexp $after $tag]


            set rafter [_correct_offset $rafter [expr [lindex $p1 1] + 1]]

	    return [concat $rbefore [list [list $tag $p1]] $rafter]
	} {
	    return {}
	}
    }

    proc highlight_all_apply { regexp line command } {
	foreach record [_match_all_apply $regexp $line $command] {
	    highlight [lindex $record 0] [lindex $record 1]
	}
    }

    proc _match_all_apply { regexp line command } {
	if { [regexp -indices -- ($regexp) $line p0 p1] == 1 } {

	    set before  [string range $line 0 [expr [lindex $p1 0] - 1]]
	    set rbefore [_match_all_apply $regexp $before $command]

	    set after  [string range $line [expr [lindex $p1 1] + 1] end]
	    set rafter [_match_all_apply $regexp $after $command]


	    set rafter [_correct_offset $rafter [expr [lindex $p1 1] + 1]]

	    set tag ""
	    set m1 [string range $line [lindex $p1 0] [lindex $p1 1]]
	    if { [catch { set tag [$command $m1] } rv] != 0 } {

		window.displayCR "Triggers Error: the following error ocurred" window_highlight
		window.displayCR "when attempting to execute the procedure '$command':" window_highlight
		window.displayCR "$rv" window_highlight

	    }
	    if { $tag != "" } {
	        return [concat $rbefore [list [list $tag $p1]] $rafter]
	    } {
		return [concat $rbefore [list] $rafter]
	    }
	} {
	    return {}
	}
    }


    proc match_triggers line {
        global trigger_data highlights

	set candidates {}
        foreach rc $trigger_data {
	    foreach { _ _ r _ _ _ nocase _ } $rc {}
	    if { $nocase } {
		if { [regexp -nocase -- $r $line] } {
		    lappend candidates $rc
		}
	    } { 
		if { [regexp -- $r $line] } {
		    lappend candidates $rc
		}
	    }
        }

	set highlights {}

	foreach rc $candidates {
	    foreach { _ _ r c _ cont nocase _ } $rc {}

	    if { $nocase } {
		if { [regexp -indices -nocase -- $r $line p0 p1 p2 p3 p4 p5 p6 p7 p8 p9] } {
                    foreach { m p } [list m0 $p0 m1 $p1 m2 $p2 m3 $p3 m4 $p4 m5 $p5 m6 $p6 m7 $p7 m8 $p8 m9 $p9] {
                        if { $p == {-1 -1} } {
                            continue
                        }
                        set $m [string range $line [lindex $p 0] [lindex $p 1]]
                    }

                    eval $c
    
                    set_incoming_line $line

                    if { $cont == 0 } {
                        if { $highlights != {} } {
                            window.append_tagging_info [list $line [convert_tag_format $highlights]]
                            window.displayCR $line
                            window.assert_tagging_info $line
                        }

                        return [modules.module_ok]
                    }
		}
	    } {
                if { [regexp -indices -- $r $line p0 p1 p2 p3 p4 p5 p6 p7 p8 p9] } {
                    foreach { m p } [list m0 $p0 m1 $p1 m2 $p2 m3 $p3 m4 $p4 m5 $p5 m6 $p6 m7 $p7 m8 $p8 m9 $p9] {
                        if { $p == {-1 -1} } {
                            continue
                        }
                        set $m [string range $line [lindex $p 0] [lindex $p 1]]
                    }

                    eval $c

                    set_incoming_line $line

                    if { $cont == 0 } {
                        if { $highlights != {} } {
                            window.append_tagging_info [list $line [convert_tag_format $highlights]]
                            window.displayCR $line
                            window.assert_tagging_info $line
                        }

                        return [modules.module_ok]
                    }
                }
	    }
	}

	if { $highlights != {} } {
            window.append_tagging_info [list $line [convert_tag_format $highlights]]
            window.displayCR $line
            window.assert_tagging_info $line

	    return [modules.module_ok]
	}

        return [modules.module_deferred]
    }

    proc convert_tag_format highlights {
        set new_info [list]
        foreach highlight $highlights {
            foreach {taglist range} $highlight { break }
            foreach {from to} $range { break }
	    incr to
            set record [list $from $to $taglist]
            lappend new_info $record
        }
        return $new_info
    }

    proc cmp_priority { a b } {
	return [expr int( [lindex $a 4] - [lindex $b 4] )]
    }
    proc cmp_priority_macro { a b } {
	return [expr int( [lindex $a 6] - [lindex $b 6] )]
    }

    proc match_macros line {
        global macro_data

	set candidates {}
        foreach data $macro_data {
	    foreach { _ _ r _ _ nocase _ _ } $data {}
	    if { $nocase } {
		if { [regexp -nocase -- $r $line] } {
		    lappend candidates $data
		}
	    } {
		if { [regexp -- $r $line] } {
		    lappend candidates $data
		}
	    }
        }

        foreach data $candidates {
	    foreach { _ _ r c cont nocase _ _ } $data {}

            if { $nocase } {
                if { [regexp -indices -nocase -- $r $line p0 p1 p2 p3 p4 p5 p6 p7 p8 p9] } {
                    foreach { m p } [list m0 $p0 m1 $p1 m2 $p2 m3 $p3 m4 $p4 m5 $p5 m6 $p6 m7 $p7 m8 $p8 m9 $p9] {
                        if { $p == {-1 -1} } {
                            break
                        }
                        set $m [string range $line [lindex $p 0] [lindex $p 1]]
                    }

                    eval $c

                    if { $cont == 0 } {
                        return [modules.module_ok]
                    }
                }
            } {
                if { [regexp -indices -- $r $line p0 p1 p2 p3 p4 p5 p6 p7 p8 p9] } {
                    foreach { m p } [list m0 $p0 m1 $p1 m2 $p2 m3 $p3 m4 $p4 m5 $p5 m6 $p6 m7 $p7 m8 $p8 m9 $p9] {
                        if { $p == {-1 -1} } {
                            break
                        }
                        set $m [string range $line [lindex $p 0] [lindex $p 1]]
                    }

                    eval $c

                    if { $cont == 0 } {
                        return [modules.module_ok]
                    }
                }
            }
        }
        return [modules.module_deferred]
    }

    proc car x {
	return [lindex $x 0]
    }
    proc cdr x {
	return [lrange $x 1 end]
    }


    proc trigger { args } {
	global trigger_data_x

        set default_regexp ".*"
        set default_command ""
        set default_type ""
        set default_priority 50
        set default_world ""
        set default_continue 0
        set default_nocase 0
        set default_directive ""

        set regexp $default_regexp
        set command $default_command
        set type $default_type
        set priority $default_priority
        set world $default_world
        set continue $default_continue
        set nocase $default_nocase
        set directive $default_directive

        while { $args != {} } {
            set token [car $args]
            set args [cdr $args]
            switch -- $token {
                -regexp {
                    set regexp [car $args]
                    set args [cdr $args]
                }
		-nocase {
                    set nocase 1
		}
                -command {
                    set command [car $args]
                    set args [cdr $args]
                }
		-type {
		    set type [car $args]
		    set args [cdr $args]
		}
		-name {
		    set world [car $args]
		    set args [cdr $args]
		}
		-world {
		    set world [car $args]
		    set args [cdr $args]
		}
		-priority {
		    set priority [car $args]
		    set args [cdr $args]
		}
		-continue {
		    set continue 1
		}
		-directive {
		    set directive [car $args]
		    set args [cdr $args]
		}
                default {
                    window.displayCR "Triggers Error (trigger definition): Unrecognised option '$token'" window_highlight
                    return
                } 
            }
        }        
        lappend trigger_data_x [list $world $type $regexp $command $priority $continue $nocase $directive]
    }

    proc gag { args } {
	global gag_data_x
        set default_regexp ""
        set default_type ""
        set default_world ""

        set default_nocase 0
        set default_directive ""

	set regexp $default_regexp
	set type $default_type
	set world $default_world
	set nocase $default_nocase
	set directive $default_directive

	while { $args != {} } {
	    set token [car $args]
	    set args [cdr $args]
	    switch -- $token {
		-regexp {
                    set regexp [car $args]
		    set args [cdr $args]
		}
		-nocase {
                    set nocase 1
		}
		-type {
		    set type [car $args]
		    set args [cdr $args]
		}
		-name {
		    set world [car $args]
		    set args [cdr $args]
		}
		-world {
		    set world [car $args]
		    set args [cdr $args]
		}
		-directive {
		    set directive [car $args]
		    set args [cdr $args]
		}
		default {
		    window.displayCR "Triggers Error (gag definition): Unrecognised option '$token'" window_highlight
		    return
		}
	    }
	}
	lappend gag_data_x [list $world $type $regexp $nocase $directive]
    }    

    proc macro { args } {
	global macro_data_x
        set default_regexp ""
        set default_command ""
        set default_type ""
        set default_world ""
        set default_continue 0
        set default_nocase 0
        set default_priority 50
        set default_directive ""

	set regexp $default_regexp
	set command $default_command
	set type $default_type
	set world $default_world
	set continue $default_continue
	set nocase $default_nocase
	set priority $default_priority
	set directive $default_directive

	while { $args != {} } {
	    set token [car $args]
	    set args [cdr $args]
	    switch -- $token {
		-regexp {
                    set regexp [car $args]
		    set args [cdr $args]
		}
		-nocase {
                    set nocase 1
		}
		-command {
                    set command [car $args]
		    set args [cdr $args]
		}
		-type {
		    set type [car $args]
		    set args [cdr $args]
		}
		-name {
		    set world [car $args]
		    set args [cdr $args]
		}
		-world {
		    set world [car $args]
		    set args [cdr $args]
		}
		-continue {
		    set continue 1
		}
		-priority {
		    set priority [car $args]
		    set args [cdr $args]
		}
		-directive {
		    set directive [car $args]
		    set args [cdr $args]
		}
		default {
		    window.displayCR "Triggers Error (macro definition): Unrecognised option '$token'" window_highlight
		    return
		}
	    }
	}
	lappend macro_data_x [list $world $type $regexp $command $continue $nocase $priority $directive]
    }
}
#
#
