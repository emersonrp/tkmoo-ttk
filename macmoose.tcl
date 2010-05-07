
client.register macmoose start
client.register macmoose client_connected
client.register macmoose incoming

proc macmoose.start {} {
    global macmoose_use macmoose_log
    .output tag configure macmoose_feedback -foreground [colourdb.get darkgreen]
    .output tag configure macmoose_error -foreground [colourdb.get red]
    set macmoose_use 1
    set macmoose_log 0
    set macmenu [menu .macmoosemenu]
    $macmenu configure -tearoff 0
    $macmenu add command -label "Browser" -command "macmoose.create_browser"
    $macmenu add command -label "Help" -command macmoose.help
    $macmenu add command -label "Send Mail" -command macmoose.mail
    window.menu_tools_add_cascade "MacMOOSE" .macmoosemenu
    window.menu_tools_macintosh_accelerator "MacMOOSE" "Cmd+M"

    preferences.register macmoose {Out of Band} {
        { {directive MacMOOSELogging}
            {type boolean}
            {default On}
            {display "Log MacMOOSE\nmessages"} }
    } 
}

proc macmoose.client_connected {} {
    global macmoose_use macmoose_log
    set default_usage 1
    set macmoose_use $default_usage
    set use ""
    catch {
      set use [string tolower [worlds.get [worlds.get_current] UseModuleMacMOOSE]]
    }
    if { $use == "on" } {
        set macmoose_use 1
    } elseif { $use == "off" } {
        set macmoose_use 0
    }
    ###

    set macmoose_log 0
    set log [string tolower [worlds.get_generic On {} {} MacMOOSELogging]]
    if { $log == "on" } {
        set macmoose_log 1
    } elseif { $log == "off" } {
        set macmoose_log 0
    } 
    return [modules.module_deferred]
}

proc macmoose.stop {} {}

#

proc macmoose.incoming event {
    global macmoose_fake_args macmoose_use macmoose_log

    if { $macmoose_use == 0 } {
        return [modules.module_deferred]
    }

    set line [db.get $event line]


    if { [regexp {^_&_MacMOOSE_(.*)} $line] == 0 } {
	return [modules.module_deferred]
    }


    if { $macmoose_log == 0 } {
        db.set $event logging_ignore_incoming 1
    }



    set space [string first " " $line]
    if { $space == -1 } {
        set lhs $line
        set rhs ""
    } else {
        set lhs [string range $line 0 [expr $space-1]]
        set rhs [string range $line [expr $space+1] end]
    }

    if { [regexp {^_&_MacMOOSE_([^\(]+)\((.*)\)$} $lhs _ type the_args] } {
    } {
        set type ""
        set the_args ""
    }

    catch { unset macmoose_fake_args }
    macmoose.cgi_populate_array macmoose_fake_args $the_args
    macmoose.do_$type $rhs
    return [modules.module_ok]
}


proc macmoose.cgi_populate_array { array text } {
    upvar $array a
    foreach element [split $text "&"] {
	set keyval [split $element "="]
	set a([lindex $keyval 0]) [lindex $keyval 1]
    }
}


proc macmoose.do_set_code data {
    macmoose.populate_array keyvals $data
    set feedback_tag "macmoose_feedback"
    catch {
	if { $keyvals(TEXT_COLOR_) == "RED" } {
            set feedback_tag "macmoose_error"
	}
    }
    catch {
	window.displayCR $keyvals(FEEDBACK_) $feedback_tag
    }
}

proc macmoose.do_list_code data {
    global macmoose_keyvals macmoose_lines
    if { $data == "CODE_END" } {


	macmoose.invoke_verb_editor 
	catch { unset macmoose_keyvals }
	catch { unset macmoose_lines }
	return
    }
    if { [regexp {^CODE_LINE_: (.*)} $data null text] } {
	lappend macmoose_lines $text
	return
    }
    set macmoose_lines ""
    macmoose.populate_array macmoose_keyvals $data
}

proc macmoose.invoke_verb_editor {} {
    if { ![util.use_native_menus] } {
        return [macmoose.old.invoke_verb_editor]
    }
    global macmoose_editordb macmoose_keyvals macmoose_lines macmoose_fake_args
    set e [edit.create "Verb Editor" "Verb Editor"]
    edit.set_type $e moo-code
    edit.SCedit "" $macmoose_lines "" "Verb Editor" "Verb Editor" $e
    edit.configure_send  $e Send  "macmoose.editor_verb_send $e" 1
    edit.configure_send_and_close  $e "Send and Close"  "macmoose.editor_verb_send_and_close $e" 10
    edit.configure_close $e Close "macmoose.editor_close $e" 0

    foreach key [array names macmoose_keyvals] {
	set macmoose_editordb($e:$key) $macmoose_keyvals($key)
    }
    foreach key [array names macmoose_fake_args] {
	set macmoose_editordb($e:$key) $macmoose_fake_args($key)
    }

    edit.add_toolbar $e info

    frame $e.info -bd 0 -highlightthickness 0

    window.toolbar_look $e.info

	set msg ""
	set msg "$msg$macmoose_editordb($e:OBJ_)"
	set msg "$msg:"
	set msg "$msg$macmoose_editordb($e:CODE_NAME_)"

        label $e.info.l1 -text "$msg"

	label $e.info.la -text " args:"
	entry $e.info.args -width 15 \
	    -background [colourdb.get pink] \
	    -font [fonts.fixedwidth]
	    $e.info.args insert 0 "$macmoose_editordb($e:VERB_DOBJ_) $macmoose_editordb($e:VERB_PREP_) $macmoose_editordb($e:VERB_IOBJ_)"
	label $e.info.lp -text " perms:"
	entry $e.info.perms -width 4 \
	    -background [colourdb.get pink] \
	    -font [fonts.fixedwidth]
	    $e.info.perms insert 0 $macmoose_editordb($e:VERB_PERMS_)

	label $e.info.lo -text " owner: $macmoose_editordb($e:VERB_OWNER_)"

	pack $e.info.l1 -side left 
	pack $e.info.la -side left
	pack $e.info.args -side left
	pack $e.info.lp -side left
	pack $e.info.perms -side left
	pack $e.info.lo -side left

    edit.repack $e
}

proc macmoose.old.invoke_verb_editor {} {
    global macmoose_editordb macmoose_keyvals macmoose_lines macmoose_fake_args

    set e [edit.create "Verb Editor" "Verb Editor"]
    edit.set_type $e moo-code
    edit.SCedit "" $macmoose_lines "" "Verb Editor" "Verb Editor" $e
    edit.configure_send  $e Send  "macmoose.editor_verb_send $e" 1
    edit.configure_send_and_close  $e "Send and Close"  "macmoose.editor_verb_send_and_close $e" 10
    edit.configure_close $e Close "macmoose.editor_close $e" 0


    foreach key [array names macmoose_keyvals] {
	set macmoose_editordb($e:$key) $macmoose_keyvals($key)
    }
    foreach key [array names macmoose_fake_args] {
	set macmoose_editordb($e:$key) $macmoose_fake_args($key)
    }

    edit.add_toolbar $e info

    frame $e.info -bd 0 -highlightthickness 0

    window.toolbar_look $e.info

	set msg ""
	set msg "$msg$macmoose_editordb($e:OBJ_)"
	set msg "$msg:"
	set msg "$msg$macmoose_editordb($e:CODE_NAME_)"

        label $e.info.l1 -text "$msg"

	label $e.info.la -text " args:"
	entry $e.info.args -width 15 \
	    -background [colourdb.get pink] \
	    -font [fonts.fixedwidth]
	    $e.info.args insert 0 "$macmoose_editordb($e:VERB_DOBJ_) $macmoose_editordb($e:VERB_PREP_) $macmoose_editordb($e:VERB_IOBJ_)"
	label $e.info.lp -text " perms:"
	entry $e.info.perms -width 4 \
	    -background [colourdb.get pink] \
	    -font [fonts.fixedwidth]
	    $e.info.perms insert 0 $macmoose_editordb($e:VERB_PERMS_)

	label $e.info.lo -text " owner: $macmoose_editordb($e:VERB_OWNER_)"

	pack $e.info.l1 -side left
	pack $e.info.la -side left
	pack $e.info.args -side left
	pack $e.info.lp -side left
	pack $e.info.perms -side left
	pack $e.info.lo -side left

    edit.repack $e
}


proc macmoose.do_prop_info data {

    if { ![util.use_native_menus] } {
        return [macmoose.old.do_prop_info $data]
    }

    macmoose.populate_array info $data

    set error ""
    catch { set error $info(ERROR_) }
    if { $error != "" } {
        window.displayCR "$info(OBJ_NAME_) ($info(OBJ_)).$info(PROP_NAME_) $error" macmoose_error
	return [modules.module_ok]
    }

    global macmoose_editordb 

    set e [edit.SCedit "" "" "" "Property Editor" "Property Editor"]

    $e.t insert insert "$info(PROP_VALUE_)"
    edit.configure_send  $e Send  "macmoose.editor_property_send $e" 1
    edit.configure_send_and_close  $e "Send and Close"  "macmoose.editor_property_send_and_close $e" 10
    edit.configure_close $e Close "macmoose.editor_close $e" 0
    foreach key [array names info] {
	set macmoose_editordb($e:$key) $info($key)
    }

    edit.add_toolbar $e info

    frame $e.info -bd 0 -highlightthickness 0

    window.toolbar_look $e.info

	set msg ""
	set msg "$msg$macmoose_editordb($e:OBJ_)"
	set msg "$msg."
	set msg "$msg$macmoose_editordb($e:PROP_NAME_)"
        label $e.info.l -text "$msg"

        label $e.info.lp -text " perms:"
        entry $e.info.perms -width 4 \
	    -background [colourdb.get pink] \
	    -font [fonts.fixedwidth]
	$e.info.perms insert 0 "$macmoose_editordb($e:PROP_PERMS_)"

        label $e.info.lo -text " owner: $macmoose_editordb($e:PROP_OWNER_)"

	pack $e.info.l -side left
	pack $e.info.lp -side left
	pack $e.info.perms -side left
	pack $e.info.lo -side left

    edit.repack $e

    return [modules.module_ok]
}

proc macmoose.old.do_prop_info data {

    macmoose.populate_array info $data

    set error ""
    catch { set error $info(ERROR_) }
    if { $error != "" } {
        window.displayCR "$info(OBJ_NAME_) ($info(OBJ_)).$info(PROP_NAME_) $error" macmoose_error
	return [modules.module_ok]
    }

    global macmoose_editordb 

    set e [edit.SCedit "" "" "" "Property Editor" "Property Editor"]

    $e.t insert insert "$info(PROP_VALUE_)"
    edit.configure_send  $e Send  "macmoose.editor_property_send $e" 1
    edit.configure_send_and_close  $e "Send and Close"  "macmoose.editor_property_send_and_close $e" 10
    edit.configure_close $e Close "macmoose.editor_close $e" 0
    foreach key [array names info] {
	set macmoose_editordb($e:$key) $info($key)
    }

    frame $e.info -bd 0 -highlightthickness 0

    window.toolbar_look $e.info

	set msg ""
	set msg "$msg$macmoose_editordb($e:OBJ_)"
	set msg "$msg."
	set msg "$msg$macmoose_editordb($e:PROP_NAME_)"
        label $e.info.l -text "$msg"

        label $e.info.lp -text " perms:"
        entry $e.info.perms -width 4 \
	    -background [colourdb.get pink] \
	    -font [fonts.fixedwidth]
	$e.info.perms insert 0 "$macmoose_editordb($e:PROP_PERMS_)"

        label $e.info.lo -text " owner: $macmoose_editordb($e:PROP_OWNER_)"

	pack $e.info.l -side left
	pack $e.info.lp -side left
	pack $e.info.perms -side left
	pack $e.info.lo -side left

    set slaves [pack slaves $e]
    pack forget $slaves 
    pack $e.controls -side top -fill x
    pack $e.info -side top -fill x
    pack $e.scrollbar -side right -fill y
    pack $e.t -side left

    return [modules.module_ok]
}

proc macmoose.editor_property_send_and_close editor {
    macmoose.editor_property_send $editor
    edit.destroy $editor
}

proc macmoose.editor_property_send editor {
    global macmoose_editordb
    set line "#$#MacMOOSE"
    set line "$line set_prop"
    set line "$line PREFIX_: _&_MacMOOSE_set_prop()"
    set line "$line OBJ_: $macmoose_editordb($editor:OBJ_)"
    set line "$line PROP_NAME_: $macmoose_editordb($editor:PROP_NAME_)"
    set perms [$editor.info.perms get]
    if { ($perms != "") && 
	 ($perms != $macmoose_editordb($editor:PROP_PERMS_)) } {
        set line "$line PERMS_: $perms"
    }
    set value [$editor.t get 1.0 end]
    set line "$line VALUE_: $value"
    io.outgoing $line
}

proc macmoose.do_set_prop data {
    macmoose.populate_array keyvals $data
    catch {
	window.displayCR $keyvals(ERROR_) macmoose_error
    }
    set feedback_tag macmoose_feedback
    catch {
	if { $keyvals(TEXT_COLOR_) == "RED" } {
            set feedback_tag macmoose_error
	}
    }
    catch {
	window.displayCR $keyvals(FEEDBACK_) $feedback_tag
    }
}

proc macmoose.editor_verb_send_and_close editor {
    macmoose.editor_verb_send $editor
    edit.destroy $editor
}

proc macmoose.editor_verb_send editor {
    global macmoose_editordb

    set line "#$#MacMOOSE"
    set line "$line set_code"
    set line "$line PREFIX_: _&_MacMOOSE_set_code()"
    set line "$line CODE_NAME_: $macmoose_editordb($editor:CODE_NAME_)"
    set line "$line OBJ_: $macmoose_editordb($editor:OBJ_)"

    set args [$editor.info.args get]
    set old_args "$macmoose_editordb($editor:VERB_DOBJ_) $macmoose_editordb($editor:VERB_PREP_) $macmoose_editordb($editor:VERB_IOBJ_)"

    if { ($args != "") && 
	 ($args != $old_args) && 
	 ([llength $args] == 3)} {
        set line "$line VERB_DOBJ_: [lindex $args 0]"
        set line "$line VERB_PREP_: [lindex $args 1]"
        set line "$line VERB_IOBJ_: [lindex $args 2]"
    }

    set perms [$editor.info.perms get]
    if { ($perms != "") && 
	 ($perms != $macmoose_editordb($editor:VERB_PERMS_)) } {
        set line "$line PERMS_: $perms"
    }


    set value ""
    foreach thing [edit.get_text $editor] {
	regsub -all "/" $thing "\\/" thing
	if { $value == "" } {
	    set value $thing
	} {
	    set value "$value/$thing"
	}
    }

    set line "$line VALUE_: $value"

    io.outgoing $line
}

proc macmoose.editor_close editor {
    global macmoose_editordb
    foreach {key val} [array get macmoose_editordb "$editor:*"] {
	unset macmoose_editordb($key)
    }
    edit.destroy $editor
}


###

proc macmoose.do_object_parents data {
    global macmoose_keyvals macmoose_current_object \
	macmoose_fake_args
    catch { unset macmoose_keyvals }
    macmoose.populate_array macmoose_keyvals $data

    set browser ""
    catch { set browser $macmoose_fake_args(_BROWSER_) }
    if { $browser == "" } {
        set browser [macmoose.create_browser]
    }

    set error ""
    catch { set error $macmoose_keyvals(ERROR_) }
    if { $error != "" } {
        window.displayCR "$error" macmoose_error
        return [modules.module_ok]
    } 

    set object_menu {}
    set names [split $macmoose_keyvals(PARENT_NAMES_) "/"]
    foreach item [split $macmoose_keyvals(PARENT_OBJS_) "/"] {
	if { $item != "" } { 
	    set obj $item
	    set name [lindex $names 0]
	    regsub { *\(#.*\)$} $name {} name
	    lappend object_menu [list "$obj" "$name"]
	}
	set names [lrange $names 1 end]
    }
    db.set $browser object_menu $object_menu

    macmoose.post_object_menu $browser


    macmoose.object_info $browser $obj
}

proc macmoose.do_object_info data {
    global macmoose_keyvals
    catch { unset macmoose_keyvals }
    macmoose.populate_array macmoose_keyvals $data
    macmoose.invoke_browser
}

proc macmoose.invoke_browser {} {
    global macmoose_keyvals macmoose_current_object \
	macmoose_fake_args

    set browser ""
    catch { set browser $macmoose_fake_args(_BROWSER_) }

    if { $browser == "" } {
        set browser [macmoose.create_browser]
    }

        $browser.lists.v.verbs.l delete 0 end
        foreach verb [lsort [split $macmoose_keyvals(VERBS_) "/"]] {
	    if { $verb == "" } { continue }
	    $browser.lists.v.verbs.l insert end $verb
        }

        $browser.lists.p.props.l delete 0 end
        foreach prop [lsort [split $macmoose_keyvals(PROPS_) "/"]] {
	    if { $prop == "" } { continue }
	    $browser.lists.p.props.l insert end $prop
        }




    wm title $browser "Browser on $macmoose_keyvals(OBJ_NAME_)"

    set macmoose_current_object $macmoose_keyvals(OBJ_)
    db.set $browser current_object $macmoose_keyvals(OBJ_)

    set found 0
    set object_menu [db.get $browser object_menu]
    foreach object_name $object_menu {
	set object [lindex $object_name 0]
	set name [lindex $object_name 1]
	if { ($object == $macmoose_keyvals(OBJ_)) &&
	     ($name   == $macmoose_keyvals(OBJ_NAME_)) } {
	     set found 1
	     break;
	}
    }
    if { $found != 1 } {
	lappend object_menu [list "$macmoose_keyvals(OBJ_)" "$macmoose_keyvals(OBJ_NAME_)"]
	db.set $browser object_menu $object_menu
        macmoose.post_object_menu $browser
    }
}

proc macmoose.object_info { browser object } {
    set line "#$#MacMOOSE object_info"
    set line "$line OBJ_: $object"
    set special "_BROWSER_=$browser"
    set line "$line PREFIX_: _&_MacMOOSE_object_info($special)"
    io.outgoing $line
}

proc macmoose.object_parents { browser object } {
    set line "#$#MacMOOSE object_parents"
    set line "$line OBJ_: $object"
    set special "_BROWSER_=$browser"
    set line "$line PREFIX_: _&_MacMOOSE_object_parents($special)"
    io.outgoing $line
}

proc macmoose.old.post_object_menu browser {
    $browser.controls.top.o.m delete 0 end
    set object_menu [db.get $browser object_menu]
    foreach object_name $object_menu {
	set object [lindex $object_name 0]
	set name [lindex $object_name 1]
        $browser.controls.top.o.m add command \
	    -label "$name ($object)" \
	    -command "macmoose.object_info $browser $object"
    }
}

proc macmoose.list_code { browser code_name } {
    set current_object [db.get $browser current_object]
    if { $current_object == "" } { return }
    set line "#$#MacMOOSE list_code"
    set line "$line OBJ_: $current_object"
    regsub -all {\*} $code_name {} code_name
    set code_name [lindex $code_name 0]
    set line "$line CODE_NAME_: $code_name"
    set line "$line PREFIX_: _&_MacMOOSE_list_code(CODE_NAME_=$code_name&OBJ_=$current_object)"
    io.outgoing $line
}

proc macmoose.prop_info { browser prop_name } {
    set current_object [db.get $browser current_object]
    if { $current_object == "" } { return }
    set line "#$#MacMOOSE prop_info"
    set line "$line OBJ_: $current_object"
    set line "$line PROP_NAME_: $prop_name"
    set line "$line PREFIX_: _&_MacMOOSE_prop_info()"
    io.outgoing $line
}



proc macmoose.do_declare_code data {
    macmoose.populate_array info $data

    set error ""
    catch { set error $info(ERROR_) }
    if { $error != "" } {
        window.displayCR "Whoops!: $error" macmoose_error
        return [modules.module_ok]
    }       

    set ok 0
    catch { set ok $info(DECLARE_CODE_) }
    if { $ok == 1 } {
	window.displayCR "Code Added." macmoose_feedback
    } {
    }
    return [modules.module_ok]
}

proc macmoose.do_declare_prop data {
    macmoose.populate_array info $data

    set error ""
    catch { set error $info(ERROR_) }
    if { $error != "" } {
        window.displayCR "Whoops!: $error" macmoose_error
        return [modules.module_ok]
    }       

    set ok 0
    catch { set ok $info(DECLARE_PROP_) }
    if { $ok == 1 } {
	window.displayCR "Property Added." macmoose_feedback
    } {
    }
    return [modules.module_ok]
}


proc macmoose.add_dialog w {
    global macmoose_add macmoose_current_object
    switch $macmoose_add {
	script {
	    
	    set name [$w.s.name get]
	    set perms [$w.s.perms get]
	    set args [$w.s.args get]
		set dobj [lindex $args 0]
		set prep [lindex $args 1]
		set iobj [lindex $args 2]
	    
	    if { $name == "" } {
		return
	    }

            set obj $macmoose_current_object
            set obj [db.get $w browser current_object]

	    set line "#$#MacMOOSE declare_code"
	    set line "$line CODE_NAME_: $name"
	    set line "$line OBJ_: $obj"
	    set line "$line VERB_DOBJ_: $dobj"
	    set line "$line VERB_PREP_: $prep"
	    set line "$line VERB_IOBJ_: $iobj"
	    set line "$line PERMS_: $perms"
            set line "$line PREFIX_: _&_MacMOOSE_declare_code()"

	}
	property {
	    set name [$w.p.name get]
	    set perms [$w.p.perms get]

	    if { $name == "" } {
		return
	    }

            set obj $macmoose_current_object
            set obj [db.get $w browser current_object]

	    set line "#$#MacMOOSE declare_prop"
	    set line "$line PROP_NAME_: $name"
	    set line "$line OBJ_: $obj"
	    set line "$line PERMS_: $perms"
            set line "$line PREFIX_: _&_MacMOOSE_declare_prop()"

	}
    }
    io.outgoing $line
    macmoose.object_info [db.get $w browser] $obj
}






proc macmoose.add_script_or_property browser {
    global macmoose_add
    set macmoose_add script

    set w .[util.unique_id "macmoose_add"]

    catch { destroy $w; db.drop $w }
    toplevel $w
    window.configure_for_macintosh $w

    window.place_nice $w

    $w configure -bd 0

    wm iconname $w "Add script or property"
    wm title $w "Add script or property"

    db.set $w browser $browser

    label $w.l -text "add a script or property"

    frame $w.s -bd 0 -highlightthickness 0
	radiobutton $w.s.r -text "script" \
	    -anchor w \
	    -variable macmoose_add -value script \
	    -width 10
	label $w.s.lname -text "name:"
	entry $w.s.name \
            -width 15 \
            -background [colourdb.get pink] \
            -font [fonts.fixedwidth]

	label $w.s.lperms -text "perms:"
	entry $w.s.perms \
            -width 4 \
            -background [colourdb.get pink] \
            -font [fonts.fixedwidth]

	    $w.s.perms insert 0 "rd"

	label $w.s.largs -text "args:"
	entry $w.s.args \
            -width 15 \
            -background [colourdb.get pink] \
            -font [fonts.fixedwidth]

	    $w.s.args insert 0 "none none none"

	pack $w.s.r -side left
	pack $w.s.lname -side left
	pack $w.s.name -side left
	pack $w.s.lperms -side left
	pack $w.s.perms -side left
	pack $w.s.largs -side left
	pack $w.s.args -side left

    frame $w.p -bd 0 -highlightthickness 0
	radiobutton $w.p.r -text "property" \
	    -anchor w \
	    -variable macmoose_add -value property \
	    -width 10
	label $w.p.lname -text "name:"
	entry $w.p.name \
            -width 15 \
            -background [colourdb.get pink] \
            -font [fonts.fixedwidth]

	label $w.p.lperms -text "perms:"
	entry $w.p.perms \
            -width 4 \
            -background [colourdb.get pink] \
            -font [fonts.fixedwidth]

	    $w.p.perms insert 0 "rc"

	pack $w.p.r -side left
	pack $w.p.lname -side left
	pack $w.p.name -side left
	pack $w.p.lperms -side left
	pack $w.p.perms -side left

    pack $w.l -side top
    pack $w.s -side top -expand 1 -fill x
    pack $w.p -side top -expand 1 -fill x

    frame $w.controls -bd 0 -highlightthickness 0

    button $w.controls.a -text "Add" -command "macmoose.add_dialog $w"
    button $w.controls.c -text "Close" -command "destroy $w; db.drop $w"

    global tcl_platform
    if { $tcl_platform(platform) != "macintosh" } {
        bind $w <Escape> "destroy $w; db.drop $w"
    }


    pack $w.controls.a $w.controls.c -side left \
	-padx 5 -pady 5
    pack $w.controls -side bottom 
    window.focus $w
}

proc macmoose.toplevel w {
    return [winfo toplevel $w]
}

proc macmoose.post_object_menu browser {
    if { ![util.use_native_menus] } {
	macmoose.old.post_object_menu $browser
	return
    }
    $browser.cmenu.object delete 0 end
    set object_menu [db.get $browser object_menu]
    if { $object_menu != {} } {
        foreach object_name $object_menu {
            set object [lindex $object_name 0]  
            set name [lindex $object_name 1]
            $browser.cmenu.object add command \
                -label "$name ($object)" \
                -command "macmoose.object_info $browser $object"
	    window.hidemargin $browser.cmenu.object
        }
    } {
        $browser.cmenu.object add command \
            -label "No object selected" \
	    -state disabled
	window.hidemargin $browser.cmenu.object
    }
    $browser.cmenu.object add separator
    $browser.cmenu.object add command -label "Close" \
	-underline 0 \
        -command "macmoose.destroy_browser $browser"
    window.menu_macintosh_accelerator $browser.cmenu.object "Close" "Cmd+Q"
    window.hidemargin $browser.cmenu.object
}

proc macmoose.destroy_browser browser {
    destroy $browser
    db.drop $browser
}

proc macmoose.create_browser {} {
    if { ![util.use_native_menus] } {
        return [macmoose.old.create_browser]
    }

    set browser .[util.unique_id "macmoose_browser"]

    catch { destroy $browser; db.drop $browser }
    toplevel $browser
    window.configure_for_macintosh $browser

    window.place_nice $browser

    menu $browser.cmenu

    $browser configure -bd 0 -menu $browser.cmenu

    wm iconname $browser "Macmoose"
    wm title $browser "Macmoose"

    db.set $browser current_object ""
    db.set $browser object_menu {}

    $browser.cmenu add cascade -label "Object" -menu $browser.cmenu.object \
	-underline 0

    menu $browser.cmenu.object -tearoff 0

    $browser.cmenu add cascade -label "Tools" -menu $browser.cmenu.tools \
	-underline 0
    menu $browser.cmenu.tools -tearoff 0
    $browser.cmenu.tools add command -label "Add Script/Property" \
	-underline 0 \
	-command "macmoose.add_script_or_property $browser"
    window.menu_macintosh_accelerator $browser.cmenu.tools "Add Script/Property" "Cmd+A"
    window.hidemargin $browser.cmenu.tools
    $browser.cmenu.tools add command -label "New Browser" \
	-underline 0 \
	-command macmoose.create_browser
    window.menu_macintosh_accelerator $browser.cmenu.tools "New Browser" "Cmd+N"
    window.hidemargin $browser.cmenu.tools

    frame $browser.toolbar
    window.toolbar_look $browser.toolbar

	label $browser.toolbar.l -text "Browse:" -width 7 -anchor e
	entry $browser.toolbar.e \
            -font [fonts.fixedwidth] \
            -background [colourdb.get pink]

        bind $browser.toolbar.e <Return> {
            set object [%W get]
            if { $object != "" } {
                macmoose.object_parents [macmoose.toplevel %W] $object
            }
            %W delete 0 end
        }

    pack $browser.toolbar.l -side left
    pack $browser.toolbar.e -side left

    pack $browser.toolbar -side top \
        -fill x

    frame $browser.lists -bd 0 -highlightthickness 0

    frame $browser.lists.v -bd 0 -highlightthickness 0
	label $browser.lists.v.l -text "Scripts / Verbs"

        frame $browser.lists.v.verbs -bd 0 -highlightthickness 0
	    listbox $browser.lists.v.verbs.l \
		-highlightthickness 0 \
		-background #ffffff \
		-yscrollcommand "$browser.lists.v.verbs.s set"

		bind $browser.lists.v.verbs.l <Double-ButtonRelease-1> {
		    macmoose.list_code [macmoose.toplevel %W] [%W get @%x,%y]
		}

		bind $browser.lists.v.verbs.l <Triple-ButtonRelease-1> {
		}

	    scrollbar $browser.lists.v.verbs.s \
		-highlightthickness 0 \
		-command "$browser.lists.v.verbs.l yview"

	    global tcl_platform
	    if { $tcl_platform(platform) != "macintosh" } {
            window.set_scrollbar_look $browser.lists.v.verbs.s
	    }

	    pack $browser.lists.v.verbs.l -side left -fill both -expand 1
	    pack $browser.lists.v.verbs.s -side right -fill y

	pack $browser.lists.v.l -side top
	pack $browser.lists.v.verbs -side bottom -fill both -expand 1


    frame $browser.lists.p -bd 0 -highlightthickness 0
	label $browser.lists.p.l -text "Properties"

        frame $browser.lists.p.props -bd 0 -highlightthickness 0
	    listbox $browser.lists.p.props.l \
		-highlightthickness 0 \
		-background #ffffff \
		-yscrollcommand "$browser.lists.p.props.s set"
		bind $browser.lists.p.props.l <Double-ButtonRelease-1> {
		    macmoose.prop_info [macmoose.toplevel %W] [%W get @%x,%y]
		}

		bind $browser.lists.p.props.l <Triple-ButtonRelease-1> {
		}
	    scrollbar $browser.lists.p.props.s \
		-highlightthickness 0 \
		-command "$browser.lists.p.props.l yview"

	    global tcl_platform
	    if { $tcl_platform(platform) != "macintosh" } {
            window.set_scrollbar_look $browser.lists.p.props.s
	    }

	    pack $browser.lists.p.props.l -side left -fill both -expand 1
	    pack $browser.lists.p.props.s -side right -fill y

	pack $browser.lists.p.l -side top
	pack $browser.lists.p.props -side bottom -fill both -expand 1

    pack $browser.lists.v -side left -fill both -expand 1
    pack $browser.lists.p -side right -fill both -expand 1

    pack $browser.lists -side bottom -fill both -expand 1

    macmoose.post_object_menu $browser

    window.focus $browser.toolbar.e
    return $browser
}


proc macmoose.old.create_browser {} {
    set browser .[util.unique_id "macmoose_browser"]

    catch { destroy $browser; db.drop $browser }
    toplevel $browser
    window.configure_for_macintosh $browser

    window.place_nice $browser

    $browser configure -bd 0

    wm iconname $browser "Macmoose"
    wm title $browser "Macmoose"

    db.set $browser current_object ""
    db.set $browser object_menu {}

    frame $browser.controls -bd 0 -highlightthickness 0
	frame $browser.controls.top -bd 0 -highlightthickness 0
	label $browser.controls.top.l -text "Object:" -width 7 -anchor e
	menubutton $browser.controls.top.o -text "some object (#???)" \
	    -menu $browser.controls.top.o.m -relief raised -indicatoron 1

	    menu $browser.controls.top.o.m \
                -tearoff 0

	menubutton $browser.controls.top.b -text "Tools" \
	    -relief raised \
	    -menu $browser.controls.top.b.m
	menu $browser.controls.top.b.m -tearoff 0
	    $browser.controls.top.b.m add command -label "Add Script/Property" \
		-command "macmoose.add_script_or_property $browser"
	    $browser.controls.top.b.m add command -label "New Browser" \
		-command macmoose.create_browser

	frame $browser.controls.bottom -bd 0 -highlightthickness 0
	label $browser.controls.bottom.l2 -text "Browse:" -width 7 -anchor e
	entry $browser.controls.bottom.e \
	    -font [fonts.fixedwidth] \
	    -background [colourdb.get pink]
	bind $browser.controls.bottom.e <Return> {
	    set object [%W get]
	    if { $object != "" } {
                macmoose.object_parents [macmoose.toplevel %W] $object
	    }
	    %W delete 0 end
	}
	pack $browser.controls.top.l -side left
	pack $browser.controls.top.o -side left
	pack $browser.controls.top.b -side right

	pack $browser.controls.bottom.l2 -side left
	pack $browser.controls.bottom.e -side left

        pack $browser.controls.top -side top \
	    -expand 1 -fill x
        pack $browser.controls.bottom -side top \
	    -expand 1 -fill x

    frame $browser.lists -bd 0 -highlightthickness 0

    frame $browser.lists.v -bd 0 -highlightthickness 0
	label $browser.lists.v.l -text "Scripts / Verbs"

        frame $browser.lists.v.verbs -bd 0 -highlightthickness 0
	    listbox $browser.lists.v.verbs.l \
		-highlightthickness 0 \
		-background #ffffff \
		-yscrollcommand "$browser.lists.v.verbs.s set"

		bind $browser.lists.v.verbs.l <Double-ButtonRelease-1> {
		    macmoose.list_code [macmoose.toplevel %W] [%W get @%x,%y]
		}

		bind $browser.lists.v.verbs.l <Triple-ButtonRelease-1> {
		}

	    scrollbar $browser.lists.v.verbs.s \
		-highlightthickness 0 \
		-command "$browser.lists.v.verbs.l yview"

	    global tcl_platform
	    if { $tcl_platform(platform) != "macintosh" } {
            window.set_scrollbar_look $browser.lists.v.verbs.s
	    }

	    pack $browser.lists.v.verbs.l -side left -fill both -expand 1
	    pack $browser.lists.v.verbs.s -side right -fill y

	pack $browser.lists.v.l -side top
	pack $browser.lists.v.verbs -side bottom -fill both -expand 1


    frame $browser.lists.p -bd 0 -highlightthickness 0
	label $browser.lists.p.l -text "Properties"

        frame $browser.lists.p.props -bd 0 -highlightthickness 0
	    listbox $browser.lists.p.props.l \
		-highlightthickness 0 \
		-background #ffffff \
		-yscrollcommand "$browser.lists.p.props.s set"
		bind $browser.lists.p.props.l <Double-ButtonRelease-1> {
		    macmoose.prop_info [macmoose.toplevel %W] [%W get @%x,%y]
		}

		bind $browser.lists.p.props.l <Triple-ButtonRelease-1> {
		}
	    scrollbar $browser.lists.p.props.s \
		-highlightthickness 0 \
		-command "$browser.lists.p.props.l yview"

	    global tcl_platform
	    if { $tcl_platform(platform) != "macintosh" } {
            window.set_scrollbar_look $browser.lists.p.props.s
	    }

	    pack $browser.lists.p.props.l -side left -fill both -expand 1
	    pack $browser.lists.p.props.s -side right -fill y

	pack $browser.lists.p.l -side top
	pack $browser.lists.p.props -side bottom -fill both -expand 1

    pack $browser.lists.v -side left -fill both -expand 1
    pack $browser.lists.p -side right -fill both -expand 1

    pack $browser.controls -side top -fill x
    pack $browser.lists -side bottom -fill both -expand 1

    macmoose.post_object_menu $browser

    window.focus $browser.controls.bottom.e
    return $browser
}

proc macmoose.populate_array {array string} {
    upvar $array a

    set key ""
    set value ""

    regsub -all {\\} $string {\\\\} string

    while { $string != "" } {
        set space [string first " " $string]
        if { $space != -1 } {
            set left [string range $string 0 [expr $space - 1]]
            set string [string range $string [expr $space + 1] end]
            if { [regexp {^[A-Z_]+_:$} $left] } {

                if { $key != "" } {
                    if { ($value == "") || ([string first " " $value] != -1) } {
                        append correct " $key \"$value\""
                    } else {
                        append correct " $key $value"
                    }
                }

                set key $left
                set value ""
            } else {
	        regsub -all {\"} $left {\\"} left 
                if { $value == "" } {
                    set value $left
                } else {
                    append value " $left"
                }
            }
        } else {
	    regsub -all {\"} $string {\\"} string 
            if { $value == "" } {
                set value $string
            } else {
                append value " $string"
            }
            break
        }
    }


    if { $key != "" } {
        if { ($value == "") || ([string first " " $value] != -1) } {
            append correct " $key \"$value\""
        } else {
            append correct " $key $value"
        }
    }

    set correct [string trimleft $correct]

    util.populate_array a $correct
}

proc macmoose.help {} {
global win
set win .[util.unique_id help]
toplevel $win
wm title $win "MacMOOSE Help"

frame $win.entry
label $win.entry.text -text "Enter help query: "
entry $win.entry.entry
button $win.entry.button -text "Search" -command {macmoose.search $win}
bind $win.entry.entry <Return> {macmoose.search $win}

frame $win.msg
text $win.msg.text -yscrollcommand "$win.msg.sby set"  -state disabled
scrollbar $win.msg.sby -orient vert -command "$win.msg.text yview"
button $win.close -text "Close" -command {destroy $win}

pack $win.entry
pack $win.entry.text -side left
pack $win.entry.entry -side left
pack $win.entry.button -side right
pack $win.msg
pack $win.msg.text -side left
pack $win.msg.sby -expand yes -fill both -side right
pack $win.close

}

proc macmoose.search win {
set topic [$win.entry.entry get]
set msg $win.msg.text
set line "#$#MacMOOSE"
set line "$line help"
set line "$line PREFIX_: _&_MacMOOSE_help(win_=$win)"
set line "$line TOPIC_: $topic"
io.outgoing $line
$msg conf -state normal
$msg insert end "$topic\n"
$msg conf -state disabled
}

proc macmoose.do_help data {
global macmoose_fake_args
set win $macmoose_fake_args(win_)
set msg $win.msg.text
$msg tag configure machelp_error -foreground [colourdb.get red]
if {$data == "HELP_START"} {
$msg conf -state normal
$msg insert end "-----\n"
$msg conf -state disabled
} 
if { [string range $data 0 8] == "HELP_LINE"} {
macmoose.populate_array keyvals $data
$msg conf -state normal
$msg insert end "\n$keyvals(HELP_LINE_)\n"
$msg conf -state disabled
} 
if {$data == "HELP_END"} {
$msg conf -state normal
$msg insert end "\n-----\n"
$msg conf -state disabled
} 
if {[string range $data 0 5] == "ERROR_"} {
macmoose.populate_array keyvals $data
$msg conf -state normal
$msg insert end "\n$keyvals(ERROR_) machelp_error\n-----\n"
$msg conf -state disabled
}
}

proc macmoose.mail {} {
global win
set win  .[util.unique_id mail]
toplevel $win
wm title $win "MAcMOOSE Send Mail"
frame $win.to
label $win.to.text -text "To:"
set to [entry $win.to.entry]


frame $win.subject
label $win.subject.text -text "Subject:"
entry $win.subject.entry

frame $win.msg
label $win.msg.text -text "Message:"
text $win.msg.msg
scrollbar $win.msg.sby -orient vert

frame $win.buttons
button $win.buttons.send -text "Send" -command {macmoose.verify_mail_recipients $win [$to get]}
button $win.buttons.cancel -text "Canel" -command {destroy $win}



pack $win.to
pack $win.to.text -side left
pack $win.to.entry -side right
pack $win.subject
pack $win.subject.text -side left
pack $win.subject.entry -side right
pack $win.msg
pack $win.msg.text  -anchor w
pack $win.msg.sby -side right -fill both -expand yes
pack $win.msg.msg
pack $win.buttons
pack $win.buttons.send -side left
pack $win.buttons.cancel -side left

$win.msg.msg conf -yscrollcommand {$win.msg.sby set}
$win.msg.sby conf -command {$win.msg.msg yview}
}


proc macmoose.verify_mail_recipients {win to} {
set to [string map {" " /} $to]
set line "#$#MacMOOSE"
set line "$line verify_mail_recipients"
set line "$line PREFIX_: _&_MacMOOSE_send_mail(win_=$win)"
set line "$line RECIPIENTS_: $to"
io.outgoing $line
}

proc macmoose.do_send_mail data {
global macmoose_fake_args
macmoose.populate_array keyvals $data
set to $keyvals(VALID_RECIPIENTS_)
set win $macmoose_fake_args(win_)
set subject [$win.subject.entry get]
set msg [$win.msg.msg get 1.0 end-1c]
set msg [string map {/ "\\/" \n /} $msg]
set line "#$#MacMOOSE"
set line "$line send_mail"
set line "$line PREFIX_: _&_MacMOOSE_recieved(win_=$win)"
set line "$line RECIPIENTS_: $to"
set line "$line SUBJECT_: $subject"
set line "$line BODY_: $msg"
io.outgoing $line
}

proc macmoose.do_recieved data {
global macmoose_fake_args
macmoose.populate_array keyvals $data
if {$keyvals(SEND_MAIL_) == 1} {
tk_dialog .[util.unique_id popup] "Mail Sent" "Mail Sent Successfully" "" 0 OK
destroy $macmoose_fake_args(win_)
} else {
tk_dialog .[util.unique_id popup] "Mail failed" "Sending Failed" "" 0 OK
}
}

#
#
