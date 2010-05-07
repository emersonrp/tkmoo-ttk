

proc history.drop id {
    global history_db
    foreach key [array names history_db "$id:"] {
	unset history_db($key)
    }
}

proc history.init { id {fixed 1} } {
    global history_db
    set history_db($id:history) {}
    set history_db($id:index) 0
    set history_db($id:fixed) $fixed
}

proc history.add { id line } {
    global history_db
    if { $line != "" } {
	lappend history_db($id:history) $line
    }
    if { [llength $history_db($id:history)] > 20 } {
	set history_db($id:history) [lrange $history_db($id:history) 1 end]
    }
    set history_db($id:index) [llength $history_db($id:history)]
}

proc history.next id {
    global history_db
    if { $history_db($id:history) == {} } {
	return ""
    }
    incr history_db($id:index)
    if { $history_db($id:index) > [llength $history_db($id:history)] } {
	if { $history_db($id:fixed) == 1 } {
	    set history_db($id:index) [llength $history_db($id:history)]
	} {
	    set history_db($id:index) 0
	}
    }
    return [lindex $history_db($id:history) $history_db($id:index)]
}

proc history.prev id {
    global history_db
    if { $history_db($id:history) == {} } {
	return ""
    }
    incr history_db($id:index) -1
    if { $history_db($id:index) < 0 } {
	if { $history_db($id:fixed) == 1 } {
	    set history_db($id:index) 0
	} {
	    set history_db($id:index) [llength $history_db($id:history)] 
	}
    }
    return [lindex $history_db($id:history) $history_db($id:index)]
}
