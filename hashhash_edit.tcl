
client.register hashhash_edit start
client.register hashhash_edit client_connected
client.register hashhash_edit incoming

proc hashhash_edit.start {} {
    global hashhash_edit_use hashhash_edit_receiving
    set hashhash_edit_receiving 0
    request.set current hashhash_edit_lines ""
    set hashhash_edit_use 0
    preferences.register hashhash_edit {Special Forces} {
        { {directive UseHashHashEditing}
            {type boolean}
            {default Off}
            {display "Allow ## editing"} }
    } 
}

proc hashhash_edit.client_connected {} {
    global hashhash_edit_use



    set default_usage 0
    set hashhash_edit_use $default_usage
    set use1 ""
    set use2 ""

    catch {
        set use1 [string tolower [worlds.get_generic Off {} {} UseHashHashEditing]]
    }
    if { $use1 == "on" } {
        set hashhash_edit_use 1
    } elseif { $use1 == "off" } {
        set hashhash_edit_use 0
    }
    ###
    return [modules.module_deferred]
}

proc hashhash_edit.incoming event {
    global hashhash_edit_use hashhash_edit_receiving

    if { $hashhash_edit_use == 0 } {
        return [modules.module_deferred]
    }

    set line [db.get $event line]

    if { [string match "## startrecord" $line] == 1 } {
        set hashhash_edit_receiving 1
        request.set current hashhash_edit_lines ""
        return [modules.module_ok]
    }

    if { $hashhash_edit_receiving == 1 } {

	if { [string match "## endrecord" $line] == 1 } {
	    set hashhash_edit_receiving 0
            hashhash_edit.editor
            hashhash_edit.unset_header
            return [modules.module_ok]
	}

        request.set current hashhash_edit_lines [concat [request.get current hashhash_edit_lines] [list $line]]

        return [modules.module_ok]
    }

    return [modules.module_deferred]
}

proc hashhash_edit.editor {} {
    set which [request.current]
    set lines [request.get $which hashhash_edit_lines]

    set title "Edit"
    set icon_title "Edit"

    edit.SCedit "" $lines "" $title $icon_title
}

proc hashhash_edit.unset_header {} {
    request.destroy current
}
#
#
