client.register local_edit start 40
client.register local_edit client_connected 40
client.register local_edit incoming 40

proc local_edit.start {} {
    global local_edit_use local_edit_receiving
    set local_edit_use 0
    set local_edit_receiving 0

    preferences.register local_edit {Out of Band} {
        {
            {directive UseModuleLocalEdit}
                {type boolean}
                {default Off}
                {display "Old-style local edit"}
        }
    }
}

proc local_edit.client_connected {} {
    global local_edit_use local_edit_receiving

    set local_edit_receiving 0

    request.set current local_edit_multiline_procedure ""
    request.set current local_edit_lines ""

    set use [string tolower [worlds.get_generic off {} {} UseModuleLocalEdit]]

    if { $use == "on" } {
        set local_edit_use 1
    } elseif { $use == "off" } {
        set local_edit_use 0
    }

    return [modules.module_deferred]
}

proc local_edit.incoming event {
    global local_edit_use local_edit_receiving

    if { $local_edit_use == 0 } { return [modules.module_deferred] }

    set line [db.get $event line]

    if { $local_edit_receiving == 1 } {
        request.set current local_edit_lines [concat [request.get current local_edit_lines] [list $line]]

        if { $line == "." } {
            set local_edit_receiving 0
            set type [request.get current _type]
            catch local_edit.do_callback_$type
            local_edit.unset_header
        }

        return [modules.module_ok]
    }

    if { [string match {#*} $line] == 0 } {
        return [modules.module_deferred]
    }

    if { [regexp {^#\$# ([-a-zA-Z0-9*]*) *(.*)} $line throwaway type rest] } {
        if { ([info procs "local_edit.do_$type"] != {}) &&
                [local_edit.parse $rest] } {
            request.set current _type $type
            local_edit.do_$type
            set local_edit_receiving 1

            request.set current local_edit_lines ""
            return [modules.module_ok]
        }
    }

    return [modules.module_deferred]
}

proc local_edit.parse header {
    request.set current _authentication-key NULL
    if { [regexp {name: (.+) upload: (.+)$} $header throwaway name upload] == 1 } {
        request.set current name $name
        request.set current upload $upload
        return 1
    }
    return 1
}

proc local_edit.authenticated {} {
    global local_edit_authentication_key
    return 1
    if { [request.get current _authentication-key] == $local_edit_authentication_key } {
        return 1
    }
    return 0
}

proc local_edit.unset_header {} {
    request.destroy current

    request.set current local_edit_multiline_procedure ""
    request.set current local_edit_lines ""
}

proc local_edit.controls {} {
    return {"LocalEdit" "local_edit.callback"}
}

proc local_edit.callback {} {
    set c .modules_local_edit_controlpanel
    catch { destroy $c }

    toplevel $c

    window.place_nice $c

    $c configure -bd 0

    wm title    $c "LocalEdit Control Panel"
    wm iconname $c "LocalEdit"

    frame $c.buttons

    ttk::checkbutton $c.buttons.usele \
        -padx 0 \
        -text "use local_edit" \
        -variable local_edit_use

    ttk::button $c.buttons.close \
        -text "Close" \
        -command "destroy $c";

    pack append $c.buttons \
        $c.buttons.usele    {left padx 4} \
        $c.buttons.close    {left padx 4}

    pack append $c $c.buttons {fillx pady 4}
}

proc local_edit.do_edit {} {
    if { [local_edit.authenticated] == 1 } {
        request.set current local_edit_multiline_procedure "edit"
    }
}

proc local_edit.do_callback_edit {} {
        set which current
        catch { set which [request.get current tag] }
        set pre [request.get $which upload]

        set lines [request.get $which local_edit_lines]
        set post ""

        set title [request.get $which name]
        set icon_title [request.get $which name]

        edit.SCedit "$pre" $lines "$post" $title $icon_title
}
