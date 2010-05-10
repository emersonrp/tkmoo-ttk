

set util_unique_id 0

proc util.unique_id token {
    global util_unique_id
    incr util_unique_id
    return "$token$util_unique_id"
}

proc util.populate_array { array text } {
    upvar $array a
    set keyword ""

    foreach item $text {
        if { $keyword != "" } {
            set a($keyword) $item
            set keyword "" 
        } {     
            set keyword $item
            regsub ":" $keyword "" keyword
        }       
    }
}       

proc util._populate_array { array text } {
    upvar $array a
    set keyword ""

    set space [string first " " $text]
    set item [string range $text 0 [expr $space - 1]]
    set text [string range $text [expr $space + 1] end]

    while { $item != "" } {

        if { $keyword != "" } {
            set a($keyword) $item
            set keyword "" 
        } {     
            set keyword $item
            regsub ":" $keyword "" keyword
        }       

        set space [string first " " $text]
        set item [string range $text 0 [expr $space - 1]]
        set text [string range $text [expr $space + 1] end]
    }
    set a($keyword) $text
}       


proc util.version {} {
    global tkmooVersion
    return $tkmooVersion
}

proc util.buildtime {} {
    global tkmooBuildTime
    return $tkmooBuildTime
}

proc util.eight {} {
    global tcl_version
    if { $tcl_version >= 8.0 } {
        return 1
    }
    return 0
}


proc util.slice { list { n 0 } } {
    set tmp {}
    foreach item $list {
        lappend tmp [lindex $item $n]
    }
    return $tmp
}

proc util.assoc { list key { n 0 } } {
    foreach item $list {
        if { [lindex $item $n] == $key } {
            return $item
        }
    }
    return {}
}
#
#
