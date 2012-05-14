proc client.new_session {} {
    set session [util.unique_id session]
    return $session
}
proc client.destroy_session session {
    db.drop $session
}

proc client.dev {} {
    global tkmooVersion
    return [string match {*-dev*} $tkmooVersion]
}

proc client.host_unreachable { host port } {
    window.displayCR "Server at $host $port is unreachable." window_highlight
}

set client_event_callbacks_x(start) {}
set client_event_callbacks_x(stop) {}
set client_event_callbacks_x(client_connected) {}
set client_event_callbacks_x(client_disconnected) {}
set client_event_callbacks_x(incoming) {}
set client_event_callbacks_x(incoming_2) {}
set client_event_callbacks_x(outgoing) {}
set client_event_callbacks_x(reconfigure_fonts) {}

proc client.register {plugin event {priority 50}} {
    global client_event_callbacks_x
    lappend client_event_callbacks_x($event) [list $plugin $priority [llength $client_event_callbacks_x($event)]]

    global client_plugin_location
    if { [info procs plugin.plugin_location] != {} } {
        set client_plugin_location($plugin) [plugin.plugin_location]
    } {
        set client_plugin_location($plugin) INTERNAL
    }
}

proc client.plugin_location plugin {
    global client_plugin_location
    if { [info exists client_plugin_location($plugin)] } {
        return $client_plugin_location($plugin)
    } {
        return INTERNAL
    }
}

proc client.plugins {} {
    global client_event_callbacks_x
    foreach event [array names client_event_callbacks_x] {
        foreach record $client_event_callbacks_x($event) {
            set plugin [lindex $record 0]
            set uniq($plugin) 1
        }
    }
    return [lsort [array names uniq]]
}

proc client.sort_registry {} {
    global client_event_callbacks client_event_callbacks_x

    foreach event [array names client_event_callbacks_x] {
    set tmp $client_event_callbacks_x($event)
    set client_event_callbacks($event) [util.slice [lsort -increasing -command client.compare_priority $tmp]]
    }
}

proc client.compare_priority { a b } {
    set rv [expr int( [lindex $a 1] - [lindex $b 1] )]
    if { $rv == 0 } {
    set rv [expr int( [lindex $a 2] - [lindex $b 2] )]
    }
    return $rv
}

proc client.reconfigure_fonts {} {
    window.reconfigure_fonts
    modules.reconfigure_fonts
}

proc client.client_connected_session session {
    db.set current session $session

    window.client_connected
    modules.client_connected

    set ce [worlds.get_generic [colourdb.get red] colourlocalecho ColourLocalEcho ColourLocalEcho]
    if { $ce != "" } {
        .output tag configure client_echo -foreground $ce
    }
}

proc client.client_connected {} {
    window.client_connected
    modules.client_connected

    set ce [worlds.get_generic [colourdb.get red] colourlocalecho ColourLocalEcho ColourLocalEcho]
    if { $ce != "" } {
        .output tag configure client_echo -foreground $ce
    }
}

proc client.client_disconnected_session session {
    window.client_disconnected
    modules.client_disconnected

    db.set current session ""
    worlds.set_current ""
    client.destroy_session $session
}

proc client.client_disconnected {} {
    window.client_disconnected
    modules.client_disconnected

    set session UNKNOWN_SESSION
    worlds.set_current ""
    client.destroy_session $session
}

proc client.incoming-character event {
    global modules_module_deferred
    if { [modules.incoming $event] == $modules_module_deferred } {
        if { [io.noCR] == 1 } {
                window.display [db.get $event line]
        } {
                window.displayCR [db.get $event line]
        }
    }
}

proc client.incoming-line event {
    global modules_module_deferred
    window.clear_tagging_info
    if { [modules.incoming $event] == $modules_module_deferred } {
         set line [db.get $event line]
         window.displayCR $line
         window.assert_tagging_info $line
    }
}

proc client.incoming event {
    global client_mode
    client.incoming-$client_mode $event
    modules.incoming_2 $event
    db.drop $event
}

proc client.outgoing line {
    global modules_module_deferred client_echo
    if { [modules.outgoing $line] == $modules_module_deferred } {
        io.outgoing $line
    }
    if { $client_echo == 1 } {
        window.displayCR $line client_echo
    }
}

proc client.set_incoming_line line {
    global client_incoming_line
    set client_incoming_line $line
}
proc client.get_incoming_line {} {
    global client_incoming_line
    return $client_incoming_line
}

proc client.default_mode {} { return line }

proc client.mode {} {
    global client_mode
    return $client_mode
}

proc client.set_mode mode {
    global client_mode
    set client_mode $mode
}

proc client.start {} {
    global client_echo

    client.sort_registry

    .output tag configure client_echo -foreground [colourdb.get red]
    set client_echo 1

    client.set_mode [client.default_mode]

    modules.start
    client.update
    io.start
    default.default
    client.default_settings
}

proc client.stop {} {
    modules.stop
    set session ""
    catch { set session [db.get current session] }
    io.stop_session $session
}

proc client.connect { host port } {
    client.set_mode [client.default_mode]

    set session [client.new_session]
    db.set $session host $host
    db.set $session port $port
    db.set .output session $session

    io.connect_session $session
}

proc client.do_login_from_dialog {} {
    set uid [.login.u.e get]
    set pwd [.login.p.e get]
    if { $uid != "" } {
        client.complete_connection [worlds.get_current] $uid $pwd
        client.default_settings
    }
    destroy .login
}

proc client.login_dialog { uid pwd } {
    set l .login
    catch { destroy $l }
    toplevel $l

    window.bind_escape_to_destroy $l

    window.place_nice $l
    window.focus $l

    grab $l
    focus $l
    set name [worlds.get [worlds.get_current] Name]
    wm title $l "Login to $name"
    wm iconname $l "Login to $name"
    ttk::frame $l.u
    ttk::label $l.u.l -text "User:"
    ttk::entry $l.u.e
    $l.u.e insert 0 $uid
    pack $l.u.l -side left
    pack $l.u.e -side right
    ttk::frame $l.p
    ttk::label $l.p.l -text "Password:"
    ttk::entry $l.p.e -show "*"
    $l.p.e insert 0 $pwd
    pack $l.p.l -side left
    pack $l.p.e -side right
    ttk::frame $l.c
    ttk::button $l.c.l -text "Login" -command "client.do_login_from_dialog"
    ttk::button $l.c.c -text "Cancel" -command "destroy $l"
    pack $l.c.l $l.c.c -side left -padx 5 -pady 5

    bind $l <Return> { client.do_login_from_dialog };

    pack $l.u -side top -fill x
    pack $l.p -side top -fill x
    pack $l.c -side bottom
    window.focus $l.u.e
}

proc client.default_settings {} {
    global window_binding window_fonts client_echo

    set font(proportional) plain
    set font(fixedwidth)   fixedwidth
    set font(default)      $font(fixedwidth)

    set which [worlds.get_generic default {} {} DefaultFont]

    .output configure -font [fonts.$font($which)]
    if { $which == "default" } {
        set window_fonts fixedwidth
    } {
        set window_fonts $which
    }

    client.set_bindings

    set echo [worlds.get_generic on {} {} LocalEcho]
    if { [string tolower $echo] == "on" } {
        client.set_echo 1
    } {
        client.set_echo 0
    }
}

proc client.set_echo echo {
    global client_echo
    set client_echo $echo
}

proc client.set_bindings {} {
    bindings.default

    set which [worlds.get_generic default {} {} KeyBindings]

    bindings.set $which
    set window_binding $which
}

proc client.connect_world world {
    global window_binding window_fonts client_echo

    set session [client.new_session]
    db.set $session world $world
    db.set .output session $session

    set mode [worlds.get_generic [client.default_mode] {} {} ClientMode]

    client.set_mode $mode

    set kludge_world [worlds.get_current]

    worlds.set_current $world

    set host ""
    set port ""
    catch { set host [worlds.get $world Host] }
    catch { set port [worlds.get $world Port] }

    if { ($host == "") || ($port == "") } {
        window.displayCR "Host or Port not defined for this World" window_highlight
    return
    }

    db.set $session host $host
    db.set $session port $port

    if { [io.connect_session $session] == 1 } {
        worlds.set_current $kludge_world
        return
    }

    worlds.set_current $world

    set uid ""
    set pwd ""
    catch {set uid [worlds.get $world Login]}
    catch {set pwd [worlds.get $world Password]}

    set use [worlds.get_generic On {} {} UseLoginDialog]

    if { ($uid == "") && ($pwd == "") && ([string tolower $use] == "on") } {
        client.login_dialog $uid $pwd
        return
    }

    client.complete_connection $world $uid $pwd

    client.default_settings
}

proc client.complete_connection { world uid pwd } {
    set cscript [worlds.get_generic "connect %u %p" {} {} ConnectScript $world]

    regsub -all {\%u} $cscript [client.protect_regsub $uid] cscript
    regsub -all {\%p} $cscript [client.protect_regsub $pwd] cscript


    if { $cscript != "" } {
        regsub "\n\$" $cscript {} cscript
        io.outgoing $cscript
    }
}

proc client.protect_regsub str {
    regsub -all -- {&} $str {\\&} str
    return $str
}

proc client.disconnect_session session {
    set dscript ""
    catch { set dscript [worlds.get [worlds.get_current] DisconnectScript] }
    if { $dscript != "" } {
        io.outgoing $dscript
    }
    io.disconnect_session $session
}

proc client.disconnect {} {
    set dscript ""
    catch { set dscript [worlds.get [worlds.get_current] DisconnectScript] }
    if { $dscript != "" } {
        io.outgoing $dscript
    }
    io.disconnect
}


proc client.update {} {
    update idletasks
    after 500 client.update
}

proc client.exit {} {
    client.stop
    destroy .
    exit
}
